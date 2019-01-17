"""Bioconda Bot"""

import time
import os

from typing import Dict, Tuple, Callable

import jwt
import cachetools

from aiohttp import web, ClientSession
from gidgethub.sansio import Event
from gidgethub.routing import Router
from gidgethub.aiohttp import GitHubAPI
import gidgethub

from . import utils
from . import __version__ as VERSION

logger = utils.setup_logger('BiocondaBot', 'INFO')  # pylint: disable=invalid-name

hooks = Router()  # pylint: disable=invalid-name
routes = web.RouteTableDef()  # pylint: disable=invalid-name


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


command = CommandDispatch()  # pylint: disable=invalid-name


class TokenManager:
    """Handles tokens for Github App"""

    #: Github API url for creating an access token for a specific installation
    #: of an app.
    CREATE_INSTALLATION_TOKEN = "/app/installations/{installation_id}/access_tokens"

    def __init__(self, session: ClientSession) -> None:
        #: Our client session
        self.session = session
        self.gh_api = GitHubAPI(session, "BiocodaBot")
        self.app_key = os.environ.get("APP_KEY_PEM")
        self.app_id = os.environ.get("APP_ID")
        self._jwt: str = None
        self._jwt_expires: int = None
        self.jwt_period = 10
        self.installation_tokens: Dict[int, Tuple[int, str]] = {}

    @property
    def jwt(self) -> str:
        now = int(time.time())
        if not self._jwt_expires or self._jwt_expires < now + 60:
            self._jwt_expires = now + self.jwt_period * 60
            payload = {
                'iat': now,
                'exp': now + self.jwt_period * 60,
                'iss': self.app_id,
            }
            token_utf8 = jwt.encode(payload, self.app_key, algorithm="RS256")
            self._jwt = token_utf8.decode("utf-8")
        return self._jwt

    async def get_auth_token(self, event):
        installation_id = event.data['installation']['id']
        expires, token = self.installation_tokens.get(installation_id, (0, ''))
        if expires and expires < int(time.time()) - 60:
            return token

        try:
            res = await self.gh_api.post(
                self.CREATE_INSTALLATION_TOKEN,
                {'installation_id': installation_id},
                data=b"",
                accept="application/vnd.github.machine-man-preview+json",
                jwt=self.jwt
            )
        except gidgethub.BadRequest:
            logger.exception("here")
            raise

        expires = time.mktime(time.strptime(res['expires_at'][:-1], "%Y-%m-%dT%H:%M:%S"))
        token = res['token']
        self.installation_tokens[installation_id] = (expires, token)
        return token

    async def get_github_api(self, event):
        return GitHubAPI(self.session, "BiocondaBot",
                         oauth_token=await self.get_auth_token(event))


@command.register("hello")
async def hello_to_you(event, ghapi, *args):
    comments_url = event.data["issue"]["comments_url"]
    comment_author = event.data["comment"]["user"]["login"]
    msg = f"Hello @{comment_author}!"
    await ghapi.post(comments_url, data={'body': msg})
    logger.info("Posted comment on #%i", event.data["issue"]["number"])


@hooks.register("issue_comment", action="created")
async def comment_created(event, ghapi, *args, **kwargs):
    """Dispatches @bioconda-bot commands

    This function watches for comments on issues. Lines starting with
    an @mention of the bot are considered commands and dispatched.
    """
    commands = [
        line.lower().split()[1:]
        for line in event.data['comment']['body'].splitlines()
        if line.startswith('@bioconda-bot ')
    ]
    for cmd, *args in commands:
        await command.dispatch(cmd, event, ghapi, *args)


@hooks.register("status")
async def demo_using_status(_event, _ghapi):
    logger.warning("Status - not handling")


@routes.post('/_gh')
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

        ghapi = await request.app['token_manager'].get_github_api(event)
        await hooks.dispatch(event, ghapi)
        request.app['gh_rate_limit'] = ghapi.rate_limit

        try:
            logger.warning('GH requests remaining: %s', ghapi.rate_limit.remaining)

        except AttributeError:
            logger.warning('Could not get number of remaining GH requests')

        return web.Response(status=200)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Failure in webhook dispatch")
        return web.Response(status=500)


@routes.get("/")
async def show_status(request):
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
    logger.info("Starting bot (version=%s)", VERSION)
    app = web.Application()
    app['lru_cache'] = cachetools.LRUCache(maxsize=500)
    app['client_session'] = ClientSession()
    async def close_session(app):
        await app['client_session'].close()
    app.on_shutdown.append(close_session)
    app['token_manager'] = TokenManager(app['client_session'])
    app.add_routes(routes)
    return app


def run_app(port):
    """Runs the bot app locally on **port**"""
    web.run_app(init_app(), port=port)
