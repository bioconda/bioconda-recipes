"""Bioconda Bot"""

import asyncio
import logging
import traceback
import os
import sys

from aiohttp import web, ClientSession
from cachetools import LRUCache
from gidgethub.sansio import Event
from gidgethub.routing import Router
from gidgethub.aiohttp import GitHubAPI

from . import utils
from . import __version__ as VERSION

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

ROUTER = Router()
CACHE = LRUCache(maxsize=500)

SECRET = os.environ.get("GITHUB_SECRET")
OAUTH_TOKEN = os.environ.get("GITHUB_TOKEN")


@ROUTER.register("issue_comment", action="created")
async def handle_comment(event, ghapi, *arg, **kwargs):
    comments_url = event.data["issue"]["comments_url"]
    comment_author = event.data["comment"]["user"]["login"]
    #is_member = event.data["comment"]["user"]["author_association"] == "MEMBER"
    logging.warning('Got comment from %s', comment_author)
    commands = [
        line.lower().split()[1:]
        for line in event.data['comment']['body'].splitlines()
        if line.startswith('@bioconda-bot ')
    ]
    logger.warning('Comands: %s', commands)

    for cmd, *args in commands:
        if cmd == "hello":
            msg = f"Hello @{comment_author}!"
            await ghapi.post(comments_url, data={'body': msg})
            logger.warning(f'User %s said hello to me. I answered', comment_author)


async def webhook_in(request):
    try:
        body = await request.read()
        event = Event.from_http(request.headers, body, secret=SECRET)
        logger.warning('GH delivery ID %s', event.delivery_id)
        if event.event == "ping":
            return web.Response(status=200)
        print('getting session', file=sys.stderr)
        async with ClientSession() as session:
            logger.warning('getting api')
            ghapi = GitHubAPI(session, "bioconda/bioconda-utils",
                              oauth_token=OAUTH_TOKEN,
                              cache=CACHE)
            # Give GitHub some time to reach internal consistency.
            logger.warning('sleeping')
            await asyncio.sleep(1)
            logger.warning('dispatching')
            await ROUTER.dispatch(event, ghapi)
        try:
            logger.warning('GH requests remaining: %s', ghapi.rate_limit.remaining)
        except AttributeError:
            logger.warning('Could not get number of remaining GH requests')
        logger.warning('done')
        return web.Response(status=200)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Something broke")
        traceback.print_exc(file=sys.stderr)
        return web.Response(status=500)


async def main(request):
    logger.warning("Serving /")
    try:
        msg = f"Running version {VERSION}"
        body = await request.read()
        print(body, sys.stderr)
        return web.Response(text=msg)
    except Exception:  # pylint: disable=broad-except
        logging.exception("Got exception serving /")
        return web.Response(status=500)

async def init_app():
    utils.setup_logger('bioconda_bot', loglevel="INFO")
    logging.error("Starting bot (version=%s)", VERSION)
    logging.warning("Starting bot (version=%s)", VERSION)
    logging.info("Starting bot (version=%s)", VERSION)
    app = web.Application()
    app.router.add_get("/", main)
    app.router.add_post("/_gh", webhook_in)
    return app

def run_app(port):
    """Runs the bot app locally on **port**"""

    loop = asyncio.get_event_loop()
    app = loop.run_until_complete(init_app())

    web.run_app(app, port=port)
