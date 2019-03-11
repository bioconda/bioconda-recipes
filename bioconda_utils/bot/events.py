"""
Github Events
"""

import logging
import re

import gidgethub.routing

from .commands import command_routes, get_pr_info
from .tasks import lint_check, PRInfo
from ..githubhandler import CheckRunStatus, CheckRunConclusion

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name
event_routes = gidgethub.routing.Router()  # pylint: disable=invalid-name

BOT_ALIAS_RE = re.compile(r'@bioconda[- ]?bot', re.IGNORECASE)


@event_routes.register("issue_comment", action="created")
async def comment_created(event, ghapi, *args, **_kwargs):
    """Dispatches @bioconda-bot commands

    This function watches for comments on issues. Lines starting with
    an @mention of the bot are considered commands and dispatched.
    """
    commands = [
        line.lower().split()[1:]
        for line in event.data['comment']['body'].splitlines()
        if BOT_ALIAS_RE.match(line)
    ]
    if not commands:
        logger.info("No command in comment")
    for cmd, *args in commands:
        logger.info("Dispatching %s - %s", cmd, args)
        await command_routes.dispatch(cmd, event, ghapi, *args)


@event_routes.register("status")
async def demo_using_status(_event, _ghapi):
    """Test function for status events"""
    logger.warning("Status - not handling")


@event_routes.register("check_suite")
async def check_suite(event, ghapi):
    """Handle check suite event

    If the action is not ``completed`` but ``requested`` (by a commit)
    or ``rerequested`` (manually), we create a new **check run** an
    queue a task to lint the PR
    """

    action = event.get('action')
    if action not in ['requested', 'rerequested']:
        return
    head_sha = event.get("check_suite/head_sha")
    if not head_sha:
        logger.error("Check_suite event has no head_sha?!")
        return
    prs = event.get("check_suite/pull_requests", [])
    if not prs:
        logger.error("Check_suite event had no associated pull requests (merge?)")

    # As per API, a check run, identified by the commit sha, can have multiple PRs
    # from different repos associated with it. Not quite sure when that can happen,
    # so we log it as error for now:
    if len(prs) > 1:
        logger.error("Multiple PRs in check run - using only first")

    issue_number = prs[0]['number']

    pr = await ghapi.get_prs(number=int(issue_number))
    if not pr:
        logger.error("No PRs with number %s?", pr['number'])
        return

    files = await ghapi.get_pr_modified_files(number=issue_number)
    recipes = [item['filename'] for item in files
               if item['filename'].endswith('/meta.yaml')]

    check_run_number = await ghapi.create_check_run("Linting modified recipes", head_sha)
    logger.warning("Created check run %s", check_run_number)

    if not recipes:
        logger.warning("Created check run %s", check_run_number)
        ghapi.modify_check_run(check_run_number,
                               status=CheckRunStatus.completed,
                               conclusion=CheckRunConclusion.success,
                               output_title="No recipes modified by PR",
                               output_summary="Didn't do anything",
                               output_text=
                               "While it's true that all modified recipes are in "
                               "good condition, it's also true that all of them are in "
                               "bad condition. Not having found any problems, I'm waving you "
                               "past me, so I can ponder that logical conundrum.")
        return

    user = pr['head']['user']['login']
    repo = pr['head']['repo']['name']
    ref = pr['head']['ref']
    pr_info = PRInfo(event.get('installation/id'), user, repo, ref, recipes, issue_number)

    lint_check.schedule(pr_info, head_sha, check_run_number, ghapi=ghapi)
