"""
Github Events
"""

import logging
import re
import asyncio

import gidgethub.routing

from .commands import command_routes
from .tasks import lint_check, create_check_run, check_circle_artifacts
from .config import APP_ID


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name
event_routes = gidgethub.routing.Router()  # pylint: disable=invalid-name

BOT_ALIAS_RE = re.compile(r'@bioconda[- ]?bot', re.IGNORECASE)


@event_routes.register("issue_comment", action="created")
async def handle_comment_created(event, ghapi, *args, **_kwargs):
    """Dispatches @bioconda-bot commands

    This function watches for comments on issues. Lines starting with
    an @mention of the bot are considered commands and dispatched.
    """
    issue_number = str(event.get('issue/number', "NA"))
    commands = [
        line.lower().split()[1:]
        for line in event.get('comment/body', '').splitlines()
        if BOT_ALIAS_RE.match(line)
    ]
    if not commands:
        logger.info("No command in comment on #%s", issue_number)
    for cmd, *args in commands:
        logger.info("Dispatching command from #%s: '%s' %s", issue_number, cmd, args)
        await command_routes.dispatch(cmd, event, ghapi, *args)


@event_routes.register("check_suite")
async def handle_check_suite(event, ghapi):
    """Handle check suite event
    """
    action = event.get('action')
    if action not in ['requested', 'rerequested']:
        return
    head_sha = event.get("check_suite/head_sha")
    create_check_run.apply_async((head_sha, ghapi))
    logger.info("Scheduled create_check_run for %s", head_sha)


@event_routes.register("check_run")
async def handle_check_run(event, ghapi):
    """Handle check run event"""
    action = event.get('action')
    app_owner = event.get("check_run/check_suite/app/owner/login", None)
    head_sha = event.get("check_run/head_sha")
    if action == "completed" and app_owner == "circleci":
        for pr in event.get("check_run/check_suite/pull_requests", []):
            pr_number = pr["number"]
            check_circle_artifacts.s(pr_number, ghapi).apply_async()
            logger.info("Scheduled check_circle_artifacts on #%s", pr_number)

    # Ignore check runs coming from other apps
    if event.get("check_run/app/id") != int(APP_ID):
        return

    if action == "rerequested":
        create_check_run.apply_async((head_sha, ghapi))
        logger.info("Scheduled create_check_run for %s", head_sha)
    elif action == "created":
        check_run_number = event.get('check_run/id')
        lint_check.apply_async((check_run_number, head_sha, ghapi))
        logger.info("Scheduled lint_check for %s %s", check_run_number, head_sha)


@event_routes.register("pull_request")
async def handle_pull_request(event, ghapi):
    action = event.get('action')
    pr_number = event.get('number')
    head_sha = event.get('pull_request/head/sha')
    logger.info("Handling pull_request/%s #%s (%s)", action, pr_number, head_sha)
    if 'action' in ('open', 'reopen', 'synchronize'):
        await asyncio.sleep(5)
        create_check_run.s(head_sha, ghapi, recreate=False).apply_async()
        logger.info("Scheduled create_check_run(recreate=False) for %s", head_sha)
