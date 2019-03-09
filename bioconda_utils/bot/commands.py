"""
Bot commands issued via issue/pull-request comments
"""

import logging
from typing import TYPE_CHECKING, Callable, Dict, Optional

from .tasks import bump, lint, PRInfo, sleep


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


async def get_pr_info(ghapi, event) -> Optional[PRInfo]:
    issue_number = int(event.get('issue/number'))
    if 'pull_request' not in event.get('issue'):
        logger.error("Issue %s is not a PR", issue_number)
        await ghapi.create_comment(issue_number, "I can only do this from a PR")
        return None
    prs = await ghapi.get_prs(number=issue_number)
    user = prs['head']['user']['login']
    repo = prs['head']['repo']['name']
    ref = prs['head']['ref']

    files = await ghapi.get_pr_modified_files(number=issue_number)
    recipes = [item['filename'] for item in files
               if item['filename'].endswith('/meta.yaml')]
    if not recipes:
        await ghapi.create_comment(issue_number, "This PR does not modify any recipes")
        return None

    installation = event.get('installation/id')
    return PRInfo(installation, user, repo, ref, recipes, issue_number)


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
async def command_bump(event, ghapi, *args):
    """Bump the build number of a recipe    """
    logger.info("Got bump command: %s", args)
    pr_info = await get_pr_info(ghapi, event)
    if pr_info:
        bump.schedule(pr_info, ghapi=ghapi)


@command_routes.register("lint")
async def command_lint(event, ghapi, *args):
    """Lint the current recipe"""
    logger.info("Got lint command: %s", args)
    pr_info = await get_pr_info(ghapi, event)
    if pr_info:
        lint.schedule(pr_info, ghapi=ghapi)


@command_routes.register("autobump")
async def command_autobump(event, ghapi, *args):
    """Run autobump on the listed recipes"""
    logger.info("Got autobump command: %s", args)
