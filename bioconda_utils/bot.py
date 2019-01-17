"""Bioconda Bot"""

import logging
import os
from typing import Dict, Callable

import aiohttp
from aiohttp import web
import gidgethub.routing

from . import utils
from . import __version__ as VERSION
from .githubhandler import GitHubAppHandler, Event

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

event_routes = gidgethub.routing.Router()  # pylint: disable=invalid-name
web_routes = web.RouteTableDef()  # pylint: disable=invalid-name


BOT_NAME = "BiocondaBot"


class CommandDispatch:
    """Another router, this one is for commands to the bot"""
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


command_routes = CommandDispatch()  # pylint: disable=invalid-name


@command_routes.register("hello")
async def hello_to_you(event, ghapi):
    """Simple demo function answering to hello"""
    comment_author = event.get("comment/user/login")
    issue_number = int(event.get("issue/number"))
    msg = f"Hello @{comment_author}!"
    await ghapi.create_comment(issue_number, msg)


@event_routes.register("issue_comment", action="created")
async def comment_created(event, ghapi, *args, **_kwargs):
    """Dispatches @bioconda-bot commands

    This function watches for comments on issues. Lines starting with
    an @mention of the bot are considered commands and dispatched.
    """
    commands = [
        line.lower().split()[1:]
        for line in event.data['comment']['body'].splitlines()
        if line.startswith(f'@{BOT_NAME} ')
    ]
    for cmd, *args in commands:
        await command_routes.dispatch(cmd, event, ghapi, *args)


@event_routes.register("status")
async def demo_using_status(_event, _ghapi):
    """Test function for status events"""
    logger.warning("Status - not handling")


@web_routes.post('/_gh')
async def webhook_dispatch(request):
    """Accepts webhooks from Github and dispatches them to event handlers"""
    try:
        body = await request.read()
        event = Event.from_http(request.headers, body)
        print('GH delivery ID %s' % event.delivery_id)
        logger.info('GH delivery ID %s', event.delivery_id)

        # Respond to liveness check
        if event.event == "ping":
            return web.Response(status=200)

        ghapi = await request.app['ghapi'].get_github_api(event)
        await event_routes.dispatch(event, ghapi)
        request.app['gh_rate_limit'] = ghapi.rate_limit

        try:
            logger.warning('GH requests remaining: %s', ghapi.rate_limit.remaining)

        except AttributeError:
            logger.warning('Could not get number of remaining GH requests')

        return web.Response(status=200)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Failure in webhook dispatch")
        return web.Response(status=500)


@web_routes.get("/")
async def show_status(request):
    """Shows the index page

    This is rendered at eg https://bioconda.herokuapps.com/
    """
    try:
        msg = f"""
        Running version {VERSION}

        {request.app.get('gh_rate_limit')}
        """
        return web.Response(text=msg)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Failure in show status")
        return web.Response(status=500)


async def init_app():
    """Initialize App

    This function is the entry point for wrappers that take an app factory
    as argument, notably gunicorn:

    $ gunicorn bioconda_utils.bot:init_app \
      --worker-class aiohttp.worker.GunicornWebWorker \
      --reload
    """

    utils.setup_logger('bioconda_utils', 'INFO', prefix="")
    logger.info("Starting bot (version=%s)", VERSION)

    app = web.Application()

    # Prepare persistent client session
    app['client_session'] = aiohttp.ClientSession()
    async def close_session(app):
        await app['client_session'].close()
    app.on_shutdown.append(close_session)

    # Prepare App Handler
    app_key = os.environ.get("APP_KEY_PEM")
    if not app_key:
        raise ValueError("Environment variable APP_KEY_PEM empty or not set")
    app_id = os.environ.get("APP_ID")
    if not app_id:
        raise ValueError("Environment variable APP_ID empty or not set")
    app['ghapi'] = GitHubAppHandler(app['client_session'], BOT_NAME, app_key, app_id)

    # Add routes collected above
    app.add_routes(web_routes)
    return app


def run_app(port):
    """Runs the bot app locally on **port**"""
    web.run_app(init_app(), port=port)
