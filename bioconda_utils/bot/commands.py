"""
Handlers for user commmands (``@biocondabot do this``)
"""

import logging
import functools
from typing import Callable, Dict, Optional

from . import tasks


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


def permissions(member: Optional[bool] = None,
                author: Optional[bool] = None,
                team: Optional[str] = None):
    """Decorator for commands checking for permissions

    Permissions are OR combined. Repeat the decorator to get AND.

    Args:
      member: if true, user must be organization member
      author: if true, user must be author, if false user must not be author
    """
    def decorator(func):
        @functools.wraps(func)
        async def wrapper(ghapi, issue_number, user, *args):
            okmsg = ""
            err = []
            if not okmsg and member is not None:
                if await ghapi.is_member(user):
                    okmsg = "User is member"
                elif not await ghapi.is_org():
                    okmsg = "Repo is not on Org"
                else:
                    err += [f"a member of {ghapi.user.capitalize()}"]
            if not okmsg and author is not None:
                prq = await ghapi.get_prs(number=issue_number)
                pr_author = prq['user']['login']
                negate = "" if author else "not "
                if (pr_author == user) == author:
                    okmsg = f"User is {negate}PR author"
                else:
                    err += [f"{negate}author of the PR"]
            if not okmsg and team is not None:
                if await ghapi.is_team_member(user, team):
                    okmsg = f"User is member of {ghapi.user}/{team}"
                else:
                    err += [f"a member of {ghapi.user}/{team}"]

            msg = okmsg or f"Permission denied. You need to be {' or '.join(err)}."

            logger.warning("Access %s: %s wants to run %s on %s#%s ('%s')",
                           "GRANTED" if okmsg else "DENIED",
                           user, func.__name__, ghapi, issue_number, msg)
            if okmsg:
                return await func(ghapi, issue_number, user, *args)
            return msg
        return wrapper
    return decorator


@command_routes.register("hello")
async def command_hello(ghapi, issue_number, user, *_args):
    """Check whether the bot is listening. If it is, it will answer."""
    msg = f"Hello @{user}!"
    if issue_number:
        await ghapi.create_comment(issue_number, msg)
        return f"I said hello on #{issue_number}"
    return msg


@command_routes.register("bump")
@permissions(member=True, author=True)
async def command_bump(ghapi, issue_number, _user, *_args):
    """Bump the build number of a recipe    """
    tasks.bump.apply_async((issue_number, ghapi))
    return f"Scheduled bump of build number for #{issue_number}"


@command_routes.register("lint")
async def command_lint(ghapi, issue_number, _user, *_args):
    """Lint the current recipe"""
    (
        tasks.get_latest_pr_commit.s(issue_number, ghapi) |
        tasks.create_check_run.s(ghapi)
    ).apply_async()
    return f"Scheduled creation of new check run for latest commit in #{issue_number}"


@command_routes.register("recheck")
async def command_recheck(ghapi, issue_number, _user, *_args):
    """Trigger check_check_run and check_circle_artifacts"""
    # queue check for artifacts
    tasks.check_circle_artifacts.s(issue_number, ghapi).apply_async()
    # queue lint check
    (
        tasks.get_latest_pr_commit.s(issue_number, ghapi) |
        tasks.create_check_run.s(ghapi)
    ).apply_async()
    return f"Scheduled check run and circle artificats verification on #{issue_number}"


@command_routes.register("rebuild")
@permissions(member=True, author=True)
async def command_rebuild(ghapi, issue_number, _user, *_args):
    """Trigger rebuild of PR as of latest sha"""
    tasks.trigger_circle_rebuild.s(issue_number, ghapi).apply_async()
    return f"Scheduled triggering of rebuild for #{issue_number}"


@command_routes.register("merge")
@permissions(member=True)
async def command_merge(ghapi, issue_number, user, *_args):
    """Merge PR"""
    comment_id = await ghapi.create_comment(issue_number, "Scheduled Upload & Merge")
    (
        tasks.merge_pr.si(issue_number, comment_id, ghapi) |
        tasks.post_result.s(issue_number, comment_id, "merge", user, ghapi)
    ).apply_async()
    return f"Scheduled merge of #{issue_number}"


@command_routes.register("autobump")
@permissions(member=True)
async def command_autobump(ghapi, _issue_number, _user, *args):
    """Run immediate Autobump on recipes"""
    if any('*' in arg for arg in args):
        return f"Wildcards in autobump not allowed"
    if len(args) > 5:
        return f"Please don't schedule more than 5 updates at once"
    tasks.run_autobump.s(args, ghapi).apply_async()
    return f"Scheduled autobump check of recipe(s) {', '.join(args)}"


@command_routes.register("schedule")
@permissions(team="core")
async def command_schedule(ghapi, issue_number, user, *args):
    """Schedule autobump on CircleCI

    Takes the maximum number of recipes to update as optional argument.
    """
    err = None
    if not args:
        err = "Schedule what?"
    else:
        if args[0] == "autobump":
            if len(args) > 2:
                err = "Too many arguments."
            else:
                if len(args) == 2:
                    max_updates = int(args[1])
                else:
                    max_updates = 5
                params = {'AUTOBUMP_OPTS': f'--max-updates {max_updates}'}

                from .config import CIRCLE_TOKEN
                from ..circleci import AsyncCircleAPI
                capi = AsyncCircleAPI(ghapi.session, token=CIRCLE_TOKEN)
                res = await capi.trigger_job(project='bioconda-utils', job='autobump',
                                             params=params)
                return "Scheduled Autobump: " + res
        else:
            err = "Unknown command"
    return err + (" Options are:\n"
                  " - `autobump [n=5]`: schedule *n* updates of autobump")
