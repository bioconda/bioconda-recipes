"""
Handlers for user commmands (``@biocondabot do this``)
"""

import logging
from typing import Callable, Dict

from .tasks import (
    bump, create_check_run, get_latest_pr_commit, check_circle_artifacts,
    trigger_circle_rebuild, merge_pr, post_result
)


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class CommandDispatch:
    """Decorator based router handling bot commands

    >>> @command_routes.register("hello")
    >>> def command_hello(event, ghapi, *args):
    >>>     logger.info("Got command 'hello %s'", " ".join(args))
    """
    def __init__(self):
        self.mapping: Dict[str, Callable] = {}

    def register(self, cmd: str) -> Callable[[Callable], Callable]:
        """Decorator adding decorated function to dispatcher"""
        def decorator(func):
            self.mapping[cmd] = func
            return func
        return decorator

    async def dispatch(self, cmd, *args, **kwargs):
        """Calls one of the registered functions"""
        if cmd in self.mapping:
            response = await self.mapping[cmd](*args, **kwargs)
            logger.info(response)
            return response
        else:
            return None


# Router for bot commands received as issue comments
command_routes = CommandDispatch()  # pylint: disable=invalid-name


@command_routes.register("hello")
async def command_hello(ghapi, issue_number, user, *_args):
    """Simple demo function answering to hello"""
    msg = f"Hello @{user}!"
    if issue_number:
        await ghapi.create_comment(issue_number, msg)
        return f"I said hello on #{issue_number}"
    return msg


@command_routes.register("bump")
async def command_bump(ghapi, issue_number, _user, *_args):
    """Bump the build number of a recipe    """
    bump.apply_async((issue_number, ghapi))
    return f"Scheduled bump of build number for #{issue_number}"


@command_routes.register("lint")
async def command_lint(ghapi, issue_number, _user, *_args):
    """Lint the current recipe"""
    (
        get_latest_pr_commit.s(issue_number, ghapi) |
        create_check_run.s(ghapi)
    ).apply_async()
    return f"Scheduled creation of new check run for latest commit in #{issue_number}"


@command_routes.register("recheck")
async def command_recheck(ghapi, issue_number, _user, *_args):
    """Trigger check_check_run and check_circle_artifacts"""
    # queue check for artifacts
    check_circle_artifacts.s(issue_number, ghapi).apply_async()
    # queue lint check
    (
        get_latest_pr_commit.s(issue_number, ghapi) |
        create_check_run.s(ghapi)
    ).apply_async()
    return f"Scheduled check run and circle artificats verification on #{issue_number}"


@command_routes.register("rebuild")
async def command_rebuild(ghapi, issue_number, _user, *_args):
    """Trigger rebuild of PR as of latest sha"""
    trigger_circle_rebuild.s(issue_number, ghapi).apply_async()
    return f"Scheduled triggering of rebuild for #{issue_number}"


@command_routes.register("merge")
async def command_merge(ghapi, issue_number, user, *_args):
    """Merge PR"""
    (
        merge_pr.s(issue_number, user, ghapi) |
        post_result.s(issue_number, "merge", user, ghapi)
    ).apply_async()
    return f"Scheduled merge of #{issue_number}"
