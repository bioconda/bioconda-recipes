"""
Celery Tasks
"""

import logging
import os
import sys
import time
import types
from collections import namedtuple
from typing import TYPE_CHECKING

from .worker import celery
from .config import BOT_NAME, BOT_EMAIL
from .. import utils
from ..recipe import Recipe
from ..githandler import TempBiocondaRepo
from ..githubhandler import CheckRunStatus, CheckRunConclusion
from ..circleci import AsyncCircleAPI

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

            self.git = TempBiocondaRepo(
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
                raise RuntimeError(f"Failed to find {branch_name}:{ref} in {self.git}")
            branch.checkout()

            return self.git
        except Exception:
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
    logger.info("Latest SHA on #%s is %s", issue_number, commit['sha'])
    return commit['sha']


@celery.task(acks_late=True)
async def create_check_run(head_sha: str, ghapi, recreate=True):
    if head_sha is None:
        logger.info("Not creating check_run, SHA is None")
        return
    LINT_CHECK_NAME = "Linting Recipe(s)"
    if not recreate:
        for check_run in await ghapi.get_check_runs(head_sha):
            if check_run.get('name') == LINT_CHECK_NAME:
                logger.warning("Check run for %s exists - not recreating",
                               head_sha)
                return
    check_run_number = await ghapi.create_check_run(LINT_CHECK_NAME, head_sha)
    logger.warning("Created check run %s for %s", check_run_number, head_sha)


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

        recipes = git.get_recipes_to_build()
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

        # Here we call the actual linter code
        utils.load_config('config.yml')
        from bioconda_utils.linting import lint as _lint, LintArgs, markdown_report

        # Workaround celery/billiard messing with sys.exit
        if isinstance(sys.exit, types.FunctionType):
            def new_exit(args=None):
                raise SystemExit(args)
            (sys.exit, old_exit) = (new_exit, sys.exit)

            try:
                df = _lint(recipes, LintArgs())
            except SystemExit as exc:
                old_exit(exc.args)
            finally:
                sys.exit = old_exit

        else:
            df = _lint(recipes, LintArgs())

    summary = "Linted recipes:\n"
    for recipe in recipes:
        summary += " - `{}`\n".format(recipe)
    summary += "\n"
    annotations = []
    if df is None:
        conclusion = CheckRunConclusion.success
        title = "All recipes in good condition"
        summary += "No problems found."
    else:
        conclusion = CheckRunConclusion.failure
        title = "Some recipes had problems"
        summary += "Please fix the issues listed below."

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
                'message': info.get('fix') or str(info)
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
async def check_circle_artifacts(pr_number: int, ghapi):
    logger.info("Starting check for artifacts on #%s as of %s", pr_number, ghapi)
    pr = await ghapi.get_prs(number=pr_number)
    head_ref = pr['head']['ref']
    head_sha = pr['head']['sha']
    head_repo = pr['head']['repo']['name']

    capi = AsyncCircleAPI(ghapi.session)
    if head_repo == "bioconda-recipes":
        path = head_ref
    else:
        path = "pull/{}".format(pr_number)

    recent_builds = await capi.list_recent_builds(path)

    current_builds = [
        build["build_num"]
        for build in recent_builds
        if build["vcs_revision"] == head_sha
    ]
    logger.info("Found builds %s for #%s (%s total)", current_builds, pr_number, len(recent_builds))

    artifacts = []
    for buildno in current_builds:
        artifacts.extend(await capi.list_artifacts(buildno))

    packages = []
    archs = {}
    for artifact in artifacts:
        if artifact.endswith(".tar.bz2"):
            base, _, fname = artifact.rpartition("/")
            repo, _, arch = base.rpartition("/")
            if base + "/repodata.json" in artifacts:
                if repo not in archs:
                    archs[repo] = set()
                archs[repo].add(arch)
                packages.append((arch, fname, artifact,
                                 "[repodata.json]({}/repodata.json)".format(base)))
            else:
                packages.append((arch, fname, artifact, ""))

    tpl = utils.jinja.get_template("artifacts.md")
    msg = tpl.render(packages=packages, archs=archs,
                     current_builds=current_builds, recent_builds=recent_builds)
    msg_head, _, _ = msg.partition("\n")
    async for comment in await ghapi.iter_comments(pr_number):
        if comment['body'].startswith(msg_head):
            await ghapi.update_comment(comment["id"], msg)
            break
    else:
        await ghapi.create_comment(pr_number, msg)
