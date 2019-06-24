"""
Celery Tasks doing the actual work

.. rubric:: Tasks

.. autosummary::

   get_latest_pr_commit
   create_check_run
   bump
   lint_check
   check_circle_artifacts
   trigger_circle_rebuild
   merge_pr
   post_result
   create_welcome_post
   run_autobump

"""

import logging
import os
from collections import namedtuple
from typing import Tuple, Set
import tempfile
import re
import asyncio

from .worker import capp
from .config import (
    BOT_NAME, BOT_EMAIL, CIRCLE_TOKEN, QUAY_LOGIN, ANACONDA_TOKEN,
    PROJECT_COLUMN_LABEL_MAP
)
from .. import utils
from .. import autobump
from .. import hosters
from ..recipe import Recipe
from ..githandler import TempBiocondaRepo, GitHandlerFailure
from ..githubhandler import CheckRunStatus, CheckRunConclusion
from ..circleci import AsyncCircleAPI
from ..upload import anaconda_upload, skopeo_upload
from .. import lint

from celery.exceptions import MaxRetriesExceededError

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name



Image = namedtuple('Image', "url name tag")
Package = namedtuple('Package', "arch fname url repodata_md")

PACKAGE_RE = re.compile(r"(.*packages)/(osx-64|linux-64|noarch)/(.+\.tar\.bz2)$")
IMAGE_RE = re.compile(r".*images/(.+)(?::|%3A)(.+)\.tar\.gz$")


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
    def __init__(self, ghapi, ref=None, issue_number=None, branch_name="master"):
        self.ghapi = ghapi
        self.orig_cwd = None
        self.git = None
        self.ref = ref
        self.branch_name = branch_name
        self.issue_number = issue_number

    async def __aenter__(self):
        logger.info("Preparing checkout: pr=%s ref=%s branch=%s repo=%s",
                    self.issue_number, self.ref, self.branch_name, self.ghapi)

        try:
            if self.issue_number:
                prs = await self.ghapi.get_prs(number=self.issue_number)
                fork_user = prs['head']['user']['login']
                fork_repo = prs['head']['repo']['name']
                branch_name = prs['head']['ref']
                ref = None
            elif self.ref:
                fork_user = None
                fork_repo = None
                branch_name = "unknown"
                ref = self.ref
            elif self.branch_name:
                fork_user = None
                fork_repo = None
                branch_name = self.branch_name
                ref = None
            else:
                logger.error("-- Failed checkout - all None?")
                return None

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

            if not ref:
                branch = self.git.get_local_branch(branch_name)
                if not branch:
                    self.git.create_local_branch(branch_name)
                    branch = self.git.get_local_branch(branch_name)
            else:
                branch = self.git.create_local_branch(branch_name, ref)
            if not branch:
                logger.error("-- Failed to checkout - no branch? (git=%s)",
                             self.git)
                return None
            branch.checkout()

            return self.git
        except Exception:
            logger.exception("-- Failed to checkout - caught exception: (git=%s)",
                             self.git)
            return None

    async def __aexit__(self, _exc_type, _exc, _tb):
        if self.orig_cwd:
            os.chdir(self.orig_cwd)
        if self.git:
            self.git.close()


@capp.task(acks_late=True, ignore_result=False)
async def get_latest_pr_commit(issue_number: int, ghapi):
    """Returns last commit"""
    commit = {'sha': None}
    async for commit in ghapi.iter_pr_commits(issue_number):
        pass
    logger.info("Latest SHA on #%s is %s", issue_number, commit['sha'])
    return commit['sha']


@capp.task(acks_late=True)
async def create_check_run(head_sha: str, ghapi, recreate=True):
    """Creates a ``check_run`` on GitHub

    Args:
      head_sha: SHA of commit for which ``check_run`` will be created
      recreate: If true, a new ``check_run`` will be created even if
                one already exists
    """
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


@capp.task(acks_late=True)
async def bump(issue_number: int, ghapi):
    """Bump the build number in each recipe in PR

    Args:
      issue_number: Number of PR to bump recipes in
    """
    logger.info("Processing bump command: %s", issue_number)
    async with Checkout(ghapi, issue_number=issue_number) as git:
        if not git:
            logger.error("Failed to checkout")
            return
        recipes = git.get_changed_recipes()
        for meta_fn in recipes:
            recipe = Recipe.from_file('recipes', meta_fn)
            recipe.reset_buildnumber(recipe.build_number + 1)
            recipe.save()
            msg = f"Bump {recipe} buildno to {recipe.build_number}"
        if not git.commit_and_push_changes(recipes, None, msg, sign=True):
            logger.error("Failed to push?!")


@capp.task(acks_late=True)
async def lint_check(check_run_number: int, ref: str, ghapi):
    """Execute linter

    Args:
      check_run_number: ID of GitHub ``check_run``
      ref: SHA of commit to check
    """
    ref_label = ref[:8] if len(ref) >= 40 else ref
    logger.info("Starting lint check for %s", ref_label)
    await ghapi.modify_check_run(check_run_number, status=CheckRunStatus.in_progress)

    async with Checkout(ghapi, ref=ref) as git:
        if not git:
            await ghapi.modify_check_run(
                check_run_number,
                status=CheckRunStatus.completed,
                conclusion=CheckRunConclusion.neutral,
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
        config = utils.load_config('config.yml')
        linter = lint.Linter(config, 'recipes')  # fixme, should be configurable
        res = linter.lint(recipes)

    messages = linter.get_messages()

    summary = "Linted recipes:\n"
    for recipe in recipes:
        summary += " - `{}`\n".format(recipe)
    summary += "\n"

    details = ['Severity | Location | Check (links to docs) | Info ',
               '---------|----------|-----------------------|------']

    annotations = []
    if not messages:  # no errors, success
        conclusion = CheckRunConclusion.success
        title = "All recipes in good condition"
        summary += "No problems found."
    elif not res:  # messages, but lint OK
        conclusion = CheckRunConclusion.neutral
        title = "Found warnings"
        summary += "Please consider fixing the issues listed below."
    else:  # fail
        conclusion = CheckRunConclusion.failure
        title = "Some recipes had problems"
        summary += "Please fix the issues listed below."

    url = 'https://bioconda.github.io/linting.html'

    for msg in messages:
        annotations.append({
            'path': msg.fname,
            'start_line': msg.start_line,
            'end_line': msg.end_line,
            'annotation_level': msg.get_level(),
            'title': msg.title,
            'message': msg.body,
        })
        # 'raw_details' can also be sent as annotation, contents are hidden
        # and unfold if 'raw details' blue button clicked.
        details.append(
            f'{msg.get_level()}|{msg.fname}:{msg.start_line}|'
            f'[{msg.check}]({url}#{str(msg.check).replace("_","-")})|{msg.title}'
        )

    actions = []
    if any(msg.canfix for msg in messages):
        actions.append({
            'label': "Fix Issues",
            'description': "Some issues can be fixed automatically",
            'identifier': 'lint_fix'
        })

    await ghapi.modify_check_run(
        check_run_number,
        status=CheckRunStatus.completed,
        conclusion=conclusion,
        output_title=title,
        output_summary=summary,
        output_text='\n'.join(details) if messages else None,
        output_annotations=annotations,
        actions=actions)


@capp.task(acks_late=True)
async def lint_fix(head_branch: str, head_sha: str, ghapi):
    """Execute linter in fix mode

    Args:
      check_run_number: ID of GitHub ``check_run``
      ref: SHA of commit to check
    """
    logger.info("Running lint fix on %s as of %s", head_branch, head_sha)
    async with Checkout(ghapi, ref=head_sha) as git:
        if not git:
            logger.error("lint_fix: Failed to checkout")
            return
        recipes = git.get_recipes_to_build()
        if not recipes:
            logger.error("No recipes? Internal error")
            return
        config = utils.load_config('config.yml')
        linter = lint.Linter(config, 'recipes')  # fixme, should be configurable
        linter.lint(recipes, fix=True)

        msg = "Fixed Lint Checks"
        logger.info("Files changed: %s", list(git.list_modified_files()))
        try:
            if git.commit_and_push_changes([], None, msg=msg, sign=True):
                logger.info("Created commit in %s", head_branch)
            else:
                logger.info("No changes to %s", head_branch)
        except GitHandlerFailure:
            logger.error("Push failed")


@capp.task(acks_late=True)
async def check_circle_artifacts(pr_number: int, ghapi):
    """Checks for packages and images uploaded to CircleCI artifacts

    Args:
       pr_number: Number of PR to check
    """
    logger.info("Starting check for artifacts on #%s as of %s", pr_number, ghapi)
    pr = await ghapi.get_prs(number=pr_number)
    head_ref = pr['head']['ref']
    head_sha = pr['head']['sha']
    head_user = pr['head']['repo']['owner']['login']
    # get path for Circle
    if head_user == ghapi.user:
        branch = head_ref
    else:
        branch = "pull/{}".format(pr_number)

    capi = AsyncCircleAPI(ghapi.session)
    artifacts = await capi.get_artifacts(branch, head_sha)
    artifact_urls = set(a[1] for a in artifacts)

    packages = []
    images = []
    repos = {}

    for path, url, buildno in artifacts:
        match = PACKAGE_RE.match(url)
        if match:
            # base     /fname
            # repo/arch/fname
            repo_url, arch, fname = match.groups()
            repodata_url = '/'.join((repo_url, arch, 'repodata.json'))
            repodata_md = ""
            if repodata_url in artifact_urls:
                repos.setdefault(repo_url, set()).add(arch)
                repodata_md = "[repodata.json]({})".format(repodata_url)
            packages.append(Package(arch, fname, url, repodata_md))
            continue
        match = IMAGE_RE.match(url)
        if match:
            name, tag = match.groups()
            images.append(Image(url, name, tag))

    tpl = utils.jinja.get_template("artifacts.md")
    msg = tpl.render(packages=packages, repos=repos, images=images)

    msg_head, _, _ = msg.partition("\n")
    async for comment in await ghapi.iter_comments(pr_number):
        if comment['body'].startswith(msg_head):
            await ghapi.update_comment(comment["id"], msg)
            break
    else:
        await ghapi.create_comment(pr_number, msg)


@capp.task(acks_late=True)
async def trigger_circle_rebuild(pr_number: int, ghapi):
    """Triggers a rebuild of the latest commit for a PR on CircleCI

    Args:
      pr_number: Number of Github PR
    """
    logger.info("Triggering rebuild of #%s", pr_number)
    pr = await ghapi.get_prs(number=pr_number)
    head_ref = pr['head']['ref']
    head_sha = pr['head']['sha']
    head_user = pr['head']['repo']['owner']['login']

    capi = AsyncCircleAPI(ghapi.session, token=CIRCLE_TOKEN)
    if head_user == ghapi.user:
        path = head_ref
    else:
        path = "pull/{}".format(pr_number)

    res = await capi.trigger_rebuild(path, head_sha)
    logger.warning("Trigger_rebuild call returned with %s", res)


@capp.task(bind=True, acks_late=True, ignore_result=False)
async def merge_pr(self, pr_number: int, comment_id: int, ghapi) -> Tuple[bool, str]:
    """Merges a PR

    - Downloads artifacts from CircleCI
    - Uploads Docker images to Quay.io
    - Uploads package to Anaconda.org
    - Collects co-authors
    - Merges with co-author trailer lines

    Args:
      pr_number: number of PR to merge
      comment_id: ID of comment in PR to use for posting progress
    """
    pr = await ghapi.get_prs(number=pr_number)
    state, message = await ghapi.check_protections(pr_number, pr['head']['sha'])
    if state is None:
        try:
            raise self.retry(countdown=20, max_retries=15)
        except MaxRetriesExceededError:
            return False, "PR cannot be merged at this time. Please try again later"
    if not state:
        return state, message
    comment = ("Upload & Merge started. Reload page to view progress.\n"
               "- [x] Checks OK\n")
    await ghapi.update_comment(comment_id, comment)

    head_ref = pr['head']['ref']
    head_sha = pr['head']['sha']
    head_user = pr['head']['repo']['owner']['login']
    # get path for Circle
    if head_user == ghapi.user:
        branch = head_ref
    else:
        branch = "pull/{}".format(pr_number)

    lines = []

    capi = AsyncCircleAPI(ghapi.session, token=CIRCLE_TOKEN)
    artifacts = await capi.get_artifacts(branch, head_sha)
    files = []
    images = []
    packages = []
    for path, url, buildno in artifacts:
        match = PACKAGE_RE.match(url)
        if match:
            repo_url, arch, fname = match.groups()
            fpath = os.path.join(arch, fname)
            files.append((url, fpath))
            packages.append(fpath)
            continue
        match = IMAGE_RE.match(url)
        if match:
            name, tag = match.groups()
            fname = f"{name}__{tag}.tar.gz"
            files.append((url, fname))
            images.append((fname, f"{name}:{tag}"))

    if not files:
        return False, "PR did not build any packages."

    comment += "- [x] Fetching {} packages and {} images\n".format(len(packages), len(images))
    await ghapi.update_comment(comment_id, comment)

    logger.info("Downloading %s", ', '.join(f for _, f in files))
    done = False
    with tempfile.TemporaryDirectory() as tmpdir:
        # Download files
        try:
            fds = []
            urls = []
            for url,path in files:
                fpath = os.path.join(tmpdir, path)
                fdir = os.path.dirname(fpath)
                if not os.path.exists(fdir):
                    os.makedirs(fdir)
                urls.append(url)
                fds.append(open(fpath, "wb"))
            await utils.AsyncRequests.async_fetch(urls, fds=fds)
            done = True
            logger.error("Done downloading")
        finally:
            for fdes in fds:
                fdes.close()
        if not done:
            return False, "Failed to download archives. Please try again later"

        # Upload Images
        uploaded = []
        for fname, dref in images:
            fpath = os.path.join(tmpdir, fname)
            ndref = "biocontainers/"+dref
            for _ in range(5):
                logger.info("Uploading: %s", ndref)
                if skopeo_upload(fpath, ndref, creds=QUAY_LOGIN):
                    break
                logger.warning("Skopeo upload failed, retrying in 5s...")
                await asyncio.sleep(5)
            else:
                logger.warning("Skopeo upload failed, giving up")
                return False, "Failed to upload image to Quay.io"
            uploaded.append(ndref)
            comment += "- [x] Uploaded image {}\n".format(ndref)
            await ghapi.update_comment(comment_id, comment)

        # Upload Packages
        for fname in packages:
            fpath = os.path.join(tmpdir, fname)
            for _ in range(5):
                logger.info("Uploading: %s", fname)
                if anaconda_upload(fpath, token=ANACONDA_TOKEN):
                    break
                logger.warning("Anaconda upload failed, retrying in 5s...")
                await asyncio.sleep(5)
            else:
                logger.error("Anaconda upload failed, giving up.")
                return False, "Failed to upload package to Anaconda"
            uploaded.append(fname)
            comment += "- [x] Uploaded package {}\n".format(fname)
            await ghapi.update_comment(comment_id, comment)

        lines.append("")
        lines.append("Package uploads complete: [ci skip]")
        for pkg in uploaded:
            lines.append(" - " + pkg)
        lines.append("")

    # collect authors
    pr_author = pr['user']['login']
    coauthors: Set[str] = set()
    coauthor_logins: Set[str] = set()
    last_sha: str = None
    async for commit in ghapi.iter_pr_commits(pr_number):
        last_sha = commit['sha']
        author_login = (commit['author'] or {}).get('login')
        if author_login != pr_author:
            name = commit['commit']['author']['name']
            email = commit['commit']['author']['email']
            coauthors.add(f"Co-authored-by: {name} <{email}>")
            if author_login:
                coauthor_logins.add("@"+author_login)
            else:
                coauthor_logins.add(name)
    lines.extend(list(coauthors))

    message = "\n".join(lines)
    comment += "- Creating squash merge"
    if coauthors:
        comment += " (with co-authors {})".format(", ".join(coauthor_logins))
    comment += "\n"
    await ghapi.update_comment(comment_id, comment)

    res, msg = await ghapi.merge_pr(pr_number, sha=last_sha,
                                    message="\n".join(lines) if lines else None)
    if not res:
        return res, msg

    if not branch.startswith('pull/'):
        await ghapi.delete_branch(branch)
    return res, msg



@capp.task(acks_late=True, ignore_result=True)
async def post_result(result: Tuple[bool, str], pr_number: int, _comment_id: int,
                      prefix: str, user: str, ghapi) -> None:
    logger.error("post result: result=%s, issue=%s", result, pr_number)
    status = "succeeded" if result[0] else "failed"
    message = f"@{user}, your request to {prefix} {status}: {result[1]}"
    await ghapi.create_comment(pr_number, message)
    logger.warning("message %s", message)


@capp.task(acks_late=True)
async def create_welcome_post(pr_number: int, ghapi):
    """Post welcome message for first timers"""
    prq = await ghapi.get_prs(number=pr_number)
    pr_author = prq['user']['login']
    if await ghapi.get_pr_count(pr_author) > 1:
        logger.error("PR %#s is not %s's first", pr_number, pr_author)
        return
    logger.error("PR %#s is %s's first PR - posting welcome msg", pr_number, pr_author)
    message_tpl_str = await ghapi.get_contents(".github/welcome_new_contributor.md")
    message_tpl = utils.jinja_silent_undef.from_string(message_tpl_str)
    message = message_tpl.render(user=pr_author)
    await ghapi.create_comment(pr_number, message)


@capp.task(acks_late=True)
async def run_autobump(package_names, ghapi, *_args):
    """Runs ``autobump`` on packages

    Args:
      package_names: List of package names to check for version updates
    """
    async with Checkout(ghapi) as git:
        if not git:
            logger.error("failed to checkout master")
            return
        recipe_source = autobump.RecipeSource('recipes', package_names, [])
        scanner = autobump.Scanner(recipe_source)
        scanner.add(autobump.ExcludeSubrecipe)
        scanner.add(autobump.GitLoadRecipe, git)
        scanner.add(autobump.UpdateVersion, hosters.Hoster.select_hoster)
        scanner.add(autobump.UpdateChecksums)
        scanner.add(autobump.GitWriteRecipe, git)
        scanner.add(autobump.CreatePullRequest, git, ghapi)
        await scanner._async_run()


@capp.task(acks_late=True)
async def update_pr_project_columns(issue_number, ghapi, *_args):
    """Updates project columns for PR according to labels"""
    pr = await ghapi.get_prs(number=issue_number)
    if not pr:
        logger.error("Failed to update projects from labels: #%s is not a PR?",
                     issue_number)
        return
    logger.info("Updating projects from labels for #%s '%s'",
                issue_number, pr['title'])
    pr_labels = set(label['name'] for label in pr['labels'])

    for column_id, col_labels in PROJECT_COLUMN_LABEL_MAP.items():
        have_card = any(card.get('issue_number') == issue_number
                        for card in await ghapi.list_project_cards(column_id))
        if pr_labels.intersection(col_labels):
            if not have_card:
                await ghapi.create_project_card(column_id, number=issue_number)
        else:
            if have_card:
                await ghapi.delete_project_card_from_column(column_id, issue_number)
