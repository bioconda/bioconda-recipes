"""
Celery Tasks
"""

import logging
import os
import time
from collections import namedtuple
from typing import TYPE_CHECKING

from .worker import celery
from .config import BOT_NAME, BOT_EMAIL
from .. import utils
from ..recipe import Recipe
from ..githandler import TempGitHandler
from ..githubhandler import CheckRunStatus, CheckRunConclusion

if TYPE_CHECKING:
    from .worker import AsyncTask
    from typing import Dict


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


PRInfo = namedtuple('PRInfo', 'installation user repo ref recipes issue_number')


class Checkout:
    # We can't use contextlib.contextmanager because these are async and
    # asyncontextmanager is only available in Python >3.7
    """Async context manager checking out git repo

    Args:
      ref: optional sha checksum to checkout (only if issue_number not given)
      issue_number: optional issue number to checkout (only of ref not given)

    Returns `None` if the checkout failed, otherwise the TempGitHandler object

    >>> with Checkout(ghapi, issue_number) as git:
    >>>   if git is None:
    >>>      print("checkout failed")
    >>>   else:
    >>>      for filename in git.list_changed_files():
    """
    def __init__(self, ghapi, ref=None, issue_number=None):
        self.ghapi = ghapi
        self.orig_cwd = None
        self.git = None
        self.ref = ref
        self.issue_number = issue_number

    async def __aenter__(self):
        try:
            if self.issue_number:
                prs = await self.ghapi.get_prs(number=self.issue_number)
                fork_user = prs['head']['user']['login']
                fork_repo = prs['head']['repo']['name']
                branch_name = prs['head']['ref']
                ref = None
            else:
                fork_user = None
                fork_repo = None
                branch_name = "unknown"
                ref = self.ref

            self.git = TempGitHandler(
                password=self.ghapi.token,
                home_user=self.ghapi.user,
                home_repo=self.ghapi.repo,
                fork_user=fork_user,
                fork_repo=fork_repo
            )

            self.git.set_user(BOT_NAME, BOT_EMAIL)

            self.orig_cwd = os.getcwd()
            os.chdir(self.git.tempdir.name)

            branch = self.git.create_local_branch(branch_name, ref)
            if not branch:
                raise RuntimeError(f"Failed to checkout branch {branch_name} from {self.git}")
            branch.checkout()

            return self.git
        except Exception as exc:
            logger.exception(f"Error while checking out with {self.ghapi}")
            return None

    async def __aexit__(self, _exc_type, _exc, _tb):
        if self.orig_cwd:
            os.chdir(self.orig_cwd)
        if self.git:
            self.git.close()


@celery.task(acks_late=True, ignore_result=False)
async def get_latest_pr_commit(issue_number: int, ghapi):
    """Returns last commit"""
    commit = {'sha': None}
    async for commit in await ghapi.iter_pr_commits(issue_number):
        pass
    return commit['sha']


@celery.task(acks_late=True)
async def create_check_run(head_sha: str, ghapi):
    logger.error("create_check_run: %s %s", head_sha, ghapi)
    check_run_number = await ghapi.create_check_run("Linting Recipe(s)", head_sha)
    logger.warning("Created check run %s", check_run_number)


@celery.task(acks_late=True)
async def bump(issue_number: int, ghapi):
    """Bump the build number in each recipe"""
    logger.info("Processing bump command: %s", issue_number)
    async with Checkout(ghapi, issue_number=issue_number) as git:
        if not git:
            logger.error("Failed to checkout")
            return
        recipes = git.get_changed_recipes()
        for meta_fn in recipes:
            recipe = Recipe.from_file('recipes', meta_fn)
            buildno = int(recipe.meta['build']['number']) + 1
            recipe.reset_buildnumber(buildno)
            recipe.save()
        msg = f"Bump {recipe} buildno to {buildno}"
        if not git.commit_and_push_changes(recipes, None, msg, sign=True):
            logger.error("Failed to push?!")


@celery.task(acks_late=True)
async def lint_check(check_run_number: int, ref: str, ghapi):
    """Execute linter
    """
    ref_label = ref[:8] if len(ref) >= 40 else ref
    logger.info("Starting lint check for %s", ref_label)
    await ghapi.modify_check_run(check_run_number, status=CheckRunStatus.in_progress)

    async with Checkout(ghapi, ref=ref) as git:
        if not git:
            await ghapi.modify_check_run(
                check_run_number,
                status=CheckRunStatus.completed,
                conclusion=CheckRunConclusion.cancelled,
                output_title=
                f"Failed to check out "
                f"{ghapi.user}/{ghapi.repo}:{ref_label}"
            )
            return

        recipes = git.get_changed_recipes()
        if not recipes:
            await ghapi.modify_check_run(
                check_run_number,
                status=CheckRunStatus.completed,
                conclusion=CheckRunConclusion.neutral,
                output_title="No recipes modified",
                output_summary=
                "This branch does not modify any recipes! "
                "Please make sure this is what you intend. Upon merge, "
                "no packages would be built."
            )
            return

        utils.load_config('config.yml')
        from bioconda_utils.linting import lint as _lint, LintArgs, markdown_report
        df = _lint(recipes, LintArgs())

    annotations = []
    if df is None:
        conclusion = CheckRunConclusion.success
        title = "All recipes in good condition"
        summary = "No problems found"
    else:
        conclusion = CheckRunConclusion.failure
        title = "Some recipes had problems"
        summary = "Please fix the listed issues"

        for _, row in df.iterrows():
            check = row['check']
            info = row['info']
            recipe = row['recipe']
            annotations.append({
                'path': recipe + '/meta.yaml',
                'start_line': info.get('start_line', 1),
                'end_line': info.get('end_line', 1),
                'annotation_level': 'failure',
                'title': check,
                'message': info['fix']
            })

    await ghapi.modify_check_run(
        check_run_number,
        status=CheckRunStatus.completed,
        conclusion=conclusion,
        output_title=title,
        output_summary=summary,
        output_text=markdown_report(df),
        output_annotations=annotations)


@celery.task(acks_late=True)
def sleep(seconds, msg):
    """Demo task that just sleeps for a given number of seconds"""
    logger.info("Sleeping for %i seconds: %s", seconds, msg)
    for second in range(seconds):
        time.sleep(1)
        logger.info("Slept for %i seconds: %s", second, msg)
    logger.info("Waking: %s", msg)
