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


# We can't use contextlib.contextmanager because these are async and
# asyncontextmanager is only available in Python >3.7

class PrBranch:
    """Async context manager checking out branch for a PR

    This context manager allows making commits.
    """
    def __init__(self, ghappapi, pr_info):
        self.ghappapi = ghappapi
        self.pr_info = pr_info
        self.cwd = None
        self.git = None

    async def __aenter__(self):
        logger.error("Prepping branch %s", self.pr_info)
        token = await self.ghappapi.get_installation_token(self.pr_info.installation)
        self.git = TempGitHandler(password=token,
                                  fork_user=self.pr_info.user,
                                  fork_repo=self.pr_info.repo)
        self.git.set_user(BOT_NAME, BOT_EMAIL)

        self.cwd = os.getcwd()
        os.chdir(self.git.tempdir.name)

        branch = self.git.create_local_branch(self.pr_info.ref)
        branch.checkout()
        return self.git

    async def __aexit__(self, exc_type, exc, tb):
        os.chdir(self.cwd)
        self.git.close()


class Checkout:
    """Async context manager checking out specific commit

    Since we don't know the branch (head) we can't make commits.

    Returns `None` if the checkout failed, otherwise the TempGitHandler object

    >>> with Checkout(...) as git:
    >>>   if None:
    >>>      print("checkout failed")
    >>>   else:
    >>>      for filename in git.list_changed_files(git.get_latest_master):
    """
    def __init__(self, ghappapi, installation, user, repo, ref, branch_name="unknown"):
        self.ghappapi = ghappapi
        self.installation = installation
        self.user = user
        self.repo = repo
        self.ref = ref
        self.branch_name = branch_name
        self.orig_cwd = None
        self.git = None

    async def __aenter__(self):
        logger.info("Checking out %s/%s:%s as %s",
                    self.user, self.repo, self.ref, self.branch_name)
        token = await self.ghappapi.get_installation_token(self.installation)
        try:
            self.git = TempGitHandler(password=token,
                                      home_user=self.user, home_repo=self.repo)
            self.orig_cwd = os.getcwd()
            os.chdir(self.git.tempdir.name)
            branch = self.git.create_local_branch(self.branch_name, self.ref)
            if not branch:
                raise RuntimeError(
                    f"Failed to checkout {self.user}/{self.repo}:{self.ref}")
            branch.checkout()
            return self.git
        except Exception as exc:
            return None

    async def __aexit__(self, _exc_type, _exc, _tb):
        if self.orig_cwd:
            os.chdir(self.orig_cwd)
        if self.git:
            self.git.close()
@celery.task(bind=True, acks_late=True)
async def bump(self: "AsyncTask", pr_info_dict: "Dict", ghapi_data=None):
    """Bump the build number in each recipe"""
    pr_info = PRInfo(**pr_info_dict)
    logger.info("Processing bump command: %s", pr_info)
    async with PrBranch(self.ghappapi, pr_info) as git:
        for meta_fn in pr_info.recipes:
            recipe = Recipe.from_file('recipes', meta_fn)
            buildno = int(recipe.meta['build']['number']) + 1
            recipe.reset_buildnumber(buildno)
            recipe.save()
        msg = f"Bump {recipe} buildno to {buildno}"
        if not git.commit_and_push_changes(pr_info.recipes, pr_info.ref, msg, sign=True):
            logger.error("Failed to push?!")


async def do_lint(ghappapi, pr_info):
    async with PrBranch(ghappapi, pr_info) as git:
        utils.load_config('config.yml')
        from bioconda_utils.linting import lint as _lint, LintArgs, markdown_report
        recipes = [r[:-len('/meta.yaml')] for r in pr_info.recipes]
        df = _lint(recipes, LintArgs())
        msg = markdown_report(df)
    return df, msg


@celery.task(bind=True, acks_late=True)
async def lint(self: "AsyncTask", pr_info_dict: "Dict", ghapi_data=None):
    """Lint each recipe"""
    pr_info = PRInfo(**pr_info_dict)
    logger.info("Processing lint command: %s", pr_info)
    df, msg = await do_lint(self.ghappapi, pr_info)
    await self.ghapi.create_comment(pr_info.issue_number, msg)


@celery.task(bind=True, acks_late=True)
async def lint_check(self: "AsyncTask", pr_info_dict: "Dict", head_sha: str,
                     check_run_number: int, ghapi_data=None):
    """Lint each recipe"""
    pr_info = PRInfo(**pr_info_dict)
    logger.info("Starting lint check: %s", pr_info)
    await self.ghapi.modify_check_run(check_run_number,
                                      status=CheckRunStatus.in_progress)
    # FIXME: check if current sha is head_sha, if not, cancel
    df, msg = await do_lint(self.ghappapi, pr_info)
    if df is None:
        conclusion = CheckRunConclusion.success
        title = "All recipes in good condition"
        summary = "No problems found"
    else:
        conclusion = CheckRunConclusion.failure
        title = "Some recipes had problems"
        summary = "Please fix the listed issues"

    annotations = []
    if df is not None:
        for index, row in df.iterrows():
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

    await self.ghapi.modify_check_run(check_run_number,
                                      status=CheckRunStatus.completed,
                                      conclusion=conclusion,
                                      output_title=title, output_summary=summary,
                                      output_text=msg,
                                      output_annotations=annotations)


@celery.task(acks_late=True)
def sleep(seconds, msg):
    """Demo task that just sleeps for a given number of seconds"""
    logger.info("Sleeping for %i seconds: %s", seconds, msg)
    for second in range(seconds):
        time.sleep(1)
        logger.info("Slept for %i seconds: %s", second, msg)
    logger.info("Waking: %s", msg)
