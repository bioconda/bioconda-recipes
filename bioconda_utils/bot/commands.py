"""
Bot commands issued via issue/pull-request comments
"""

import logging
from typing import Callable, Dict, Optional

from .tasks import bump, create_check_run, get_latest_pr_commit, sleep


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
        return decorator

    async def dispatch(self, cmd, *args, **kwargs):
        """Calls one of the registered functions"""
        return await self.mapping[cmd](*args, **kwargs)


# Router for bot commands received as issue comments
command_routes = CommandDispatch()  # pylint: disable=invalid-name


@command_routes.register("hello")
async def command_hello(event, ghapi):
    """Simple demo function answering to hello"""
    comment_author = event.get("comment/user/login")
    issue_number = int(event.get("issue/number"))
    msg = f"Hello @{comment_author}!"
    await ghapi.create_comment(issue_number, msg)


@command_routes.register("sleep")
async def command_sleep(_event, _ghapi, *args):
    """Another demo command. This one triggers the sleep task via celery"""
    sleep.apply_async((20, args[0]))


@command_routes.register("bump")
async def command_bump(event, ghapi, *_args):
    """Bump the build number of a recipe    """
    issue_number = int(event.get("issue/number"))
    bump.apply_async((issue_number, ghapi))


@command_routes.register("lint")
async def command_lint(event, ghapi, *args):
    """Lint the current recipe"""
    logger.info("Got lint command: %s", args)
    issue_number = int(event.get("issue/number"))
    (
        get_latest_pr_commit.s(issue_number, ghapi) |
        create_check_run.s(ghapi)
    ).apply_async()
