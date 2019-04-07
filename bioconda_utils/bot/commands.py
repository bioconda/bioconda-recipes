"""
Handlers for user commmands (``@biocondabot do this``)
"""

import logging
from typing import Callable, Dict

from .tasks import (
    bump, create_check_run, get_latest_pr_commit, check_circle_artifacts,
    trigger_circle_rebuild
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
            return await self.mapping[cmd](*args, **kwargs)
        else:
            return False


# Router for bot commands received as issue comments
command_routes = CommandDispatch()  # pylint: disable=invalid-name


@command_routes.register("hello")
async def command_hello(event, ghapi):
    """Simple demo function answering to hello"""
    comment_author = event.get("comment/user/login")
    issue_number = int(event.get("issue/number"))
    msg = f"Hello @{comment_author}!"
    await ghapi.create_comment(issue_number, msg)
    logger.info("Answered hello on #%s", issue_number)
    return True


@command_routes.register("bump")
async def command_bump(event, ghapi, *_args):
    """Bump the build number of a recipe    """
    issue_number = int(event.get("issue/number"))
    bump.apply_async((issue_number, ghapi))
    logger.info("Scheduled 'bump' for #%s", issue_number)
    return True


@command_routes.register("lint")
async def command_lint(event, ghapi, *args):
    """Lint the current recipe"""
    issue_number = int(event.get("issue/number"))
    (
        get_latest_pr_commit.s(issue_number, ghapi) |
        create_check_run.s(ghapi)
    ).apply_async()
    logger.info("Scheduled 'create_check_run' for latest commit in #%s",
                issue_number)
    return True


@command_routes.register("recheck")
async def command_recheck(event, ghapi, *args):
    issue_number = int(event.get("issue/number"))
    # queue check for artifacts
    check_circle_artifacts.s(issue_number, ghapi).apply_async()
    logger.info("Scheduled 'check_circle_artifacts' for #%s", issue_number)
    # queue lint check
    (
        get_latest_pr_commit.s(issue_number, ghapi) |
        create_check_run.s(ghapi)
    ).apply_async()
    logger.info("Scheduled 'create_check_run' for latest commit in #%s",
                issue_number)


@command_routes.register("rebuild")
async def command_rebuild(event, ghapi, *args):
    issue_number = int(event.get("issue/number"))
    trigger_circle_rebuild.s(issue_number, ghapi).apply_async()
    logger.info("Scheduled 'trigger_circle_rebuild' for #%s", issue_number)
