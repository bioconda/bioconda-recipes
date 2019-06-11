"""
Handlers for incoming Github Events

Note:
  The incoming webhook from Github is still open and unanswered
  while these are processed. Commands should not do anything taking
  more than milliseconds.
"""

import logging
import re

import gidgethub.routing

from .commands import command_routes
from . import tasks
from .config import APP_ID


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name
event_routes = gidgethub.routing.Router()  # pylint: disable=invalid-name

BOT_ALIAS_RE = re.compile(r'@bioconda[- ]?bot', re.IGNORECASE)


@event_routes.register("issue_comment", action="created")
async def handle_comment_created(event, ghapi, *args, **_kwargs):
    """Handles comments on issues

    - dispatches @biocondabot commands
    - re-iterates commenets from non-members attempting to @mention @bioconda/xxx
    """
    issue_number = event.get('issue/number', "NA")
    comment_author = event.get("comment/user/login", "")
    comment_body = event.get("comment/body", "")

    # Ignore self mentions. This is important not only to avoid loops,
    # but critical because we are repeating what non-members say below.
    if BOT_ALIAS_RE.match('@'+comment_author):
        return

    commands = [
        line.lower().split()[1:]
        for line in comment_body.splitlines()
        if BOT_ALIAS_RE.match(line)
    ]
    for cmd, *args in commands:
        logger.info("Dispatching command from #%s: '%s' %s", issue_number, cmd, args)
        await command_routes.dispatch(cmd, ghapi, issue_number, comment_author, *args)

    if '@bioconda/' in comment_body.lower() and not await ghapi.is_member(comment_author):
        if '@bioconda/all' in comment_body.lower():
            return  # not pinging everyone
        logger.info("Repeating comment from %s on #%s to allow ping")
        quoted_msg = '\n'.join('> ' + line for line in comment_body.splitlines())
        await ghapi.create_comment(
            issue_number,
            f"Repeating comment from @{comment_author} to enable @mention:\n"
            + quoted_msg)


@event_routes.register("check_suite")
async def handle_check_suite(event, ghapi):
    """Handle check suite event
    """
    action = event.get('action')
    if action not in ['requested', 'rerequested']:
        return
    head_sha = event.get("check_suite/head_sha")
    tasks.create_check_run.apply_async((head_sha, ghapi))
    logger.info("Scheduled create_check_run for %s", head_sha)


@event_routes.register("check_run")
async def handle_check_run(event, ghapi):
    """Handle check run event"""
    action = event.get('action')
    app_owner = event.get("check_run/check_suite/app/owner/login", None)
    head_sha = event.get("check_run/head_sha")
    event_repo = event.get("repository/id")
    if action == "completed" and app_owner == "circleci":
        pr_numbers = [int(pr["number"])
                      for pr in event.get("check_run/check_suite/pull_requests", [])
                      if pr["base"]["repo"]["id"] == event_repo]
        if not pr_numbers:
            pr_numbers = await ghapi.get_prs_from_sha(head_sha, only_open=True)
        for pr_number in pr_numbers:
            tasks.check_circle_artifacts.s(pr_number, ghapi).apply_async()
            logger.info("Scheduled check_circle_artifacts on #%s", pr_number)

    # Ignore check runs coming from other apps
    if event.get("check_run/app/id") != int(APP_ID):
        logger.info("Ignoring - event came from %s", app_owner)
        return

    if action == "rerequested":
        tasks.create_check_run.apply_async((head_sha, ghapi))
        logger.info("Scheduled create_check_run for %s", head_sha)
    elif action == "created":
        check_run_number = event.get('check_run/id')
        tasks.lint_check.apply_async((check_run_number, head_sha, ghapi))
        logger.info("Scheduled lint_check for %s %s", check_run_number, head_sha)
    elif action == "requested_action":
        head_branch = event.get('check_run/check_suite/head_branch')
        requested_action = event.get('requested_action/identifier')
        if requested_action == "lint_fix":
            tasks.lint_fix.s(head_branch, head_sha, ghapi).apply_async()
            logger.info("Scheduled lint_fix for %s %s", head_branch, head_sha)
        else:
            logger.error("Unknown requested action in check run: %s", requested_action)
    else:
        logger.error("Unknown action %s", action)

@event_routes.register("pull_request")
async def handle_pull_request(event, ghapi):
    """

    pull_request can have the following actions:
    - assigned / unassigned
    - review_requested / review_request_removed
    - labeled / unlabeled
    - opened / closed / reopened
    - edited
    - ready_for_review
    - synchronize
    """
    action = event.get('action')
    pr_number = int(event.get('number'))
    head_sha = event.get('pull_request/head/sha')
    logger.info("Handling pull_request/%s #%s (%s)", action, pr_number, head_sha)
    if action == "opened":
        tasks.create_welcome_post.s(pr_number, ghapi).apply_async()

    if action in ('opened', 'reopened', 'synchronize'):
        tasks.create_check_run.s(head_sha, ghapi, recreate=False).apply_async(countdown=30)
        logger.info("Scheduled create_check_run(recreate=False) for %s", head_sha)
