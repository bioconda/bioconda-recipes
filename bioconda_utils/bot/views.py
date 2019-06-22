"""
HTTP Views (accepts and parses webhooks)
"""

import logging

from aiohttp import web, ClientSession
from aiohttp_session import get_session
from aiohttp_security import authorized_userid, check_authorized, forget, remember
from aiohttp_jinja2 import template
import uritemplate

from .events import event_routes
from ..githubhandler import Event, AiohttpGitHubHandler
from ..circleci import SlackMessage
from .. import __version__ as VERSION
from .. import utils
from .worker import capp
from .config import APP_SECRET, APP_CLIENT_ID, APP_CLIENT_SECRET



logger = logging.getLogger(__name__)  # pylint: disable=invalid-name
web_routes = web.RouteTableDef()  # pylint: disable=invalid-name
navigation_bar = []

def add_to_navbar(title):
    def wrapper(fn):
        route = web_routes[-1]
        navigation_bar.append((route.path, route.kwargs['name'], title))
        return fn
    return wrapper

@web_routes.post('/_gh')
async def github_webhook_dispatch(request):
    """Accepts webhooks from Github and dispatches them to event handlers"""
    try:
        body = await request.read()
        secret = APP_SECRET
        if secret == "IGNORE":
            logger.error("IGNORING WEBHOOK SECRET (DEBUG MODE)")
            secret = None
        event = Event.from_http(request.headers, body, secret=secret)
        # Respond to liveness check
        if event.event == "ping":
            return web.Response(status=200)

        # Log Event
        installation = event.get('installation/id')
        to_user = event.get('repository/owner/login', None)
        to_repo = event.get('repository/name', None)
        action = event.get('action', None)
        action_msg = '/' + action if action else ''
        logger.info("Received GH Event '%s%s' (%s) for %s (%s/%s)",
                    event.event, action_msg,
                    event.delivery_id,
                    installation, to_user, to_repo)

        # Get GithubAPI object for this installation
        ghapi = await request.app['ghappapi'].get_github_api(
            dry_run=False, installation=installation, to_user=to_user, to_repo=to_repo
        )

        # Dispatch the Event
        try:
            await event_routes.dispatch(event, ghapi)
            logger.info("Event '%s%s' (%s) done", event.event, action_msg, event.delivery_id)
        except Exception:  # pylint: disable=broad-except
            logger.exception("Failed to dispatch %s", event.delivery_id)
        request.app['gh_rate_limit'] = ghapi.rate_limit

        try:
            events_remaining = ghapi.rate_limit.remaining
        except AttributeError:
            events_remaining = "Unknown"
        logger.info('GH requests remaining: %s', events_remaining)

        return web.Response(status=200)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Failure in webhook dispatch")
        return web.Response(status=500)

@web_routes.post('/hooks/circleci')
async def generic_circleci_dispatch(request):
    try:
        body = await request.read()
        msg = SlackMessage(request.headers, body)
        logger.info("Got data from Circle: %s", msg)
        return web.Response(status=200)
    except Exception: # pylint: disable=broad-except
        logger.exception("Failure in circle webhook dispatch")
        return web.Response(status=500)

@web_routes.post('/hooks/{source}')
async def generic_webhook_dispatch(request):
    """Accepts webhooks and dumps them to the log, so we can see what we would be receiving"""
    try:
        source = request.match_info['source']
        body = await request.read()
        logger.error("Got generic webhook for %s", source)
        logger.error("Data: %s", body)
        return web.Response(status=200)
    except Exception: # pylint: disable=broad-except
        logger.exception("Failure in generic webhook dispatch")
        return web.Response(status=500)


@add_to_navbar(title="Home")
@web_routes.get("/", name="home")
@template('bot_index.html')
async def show_index(request):
    """Shows landing page"""
    return {}


@add_to_navbar(title="Status")
@web_routes.get("/status", name="status")
@template("bot_status.html")
async def show_status(request):
    """Shows status of workers"""
    worker_status = capp.control.inspect(timeout=0.1)
    if not worker_status:
        return {
            'error': 'Could not get worker status'
        }
    alive = worker_status.ping()
    if not alive:
        return {
            'error': 'No workers found'
        }

    return {
        'workers': {
            worker: {
                'active': worker_status.active(worker),
                'reserved': worker_status.reserved(worker),
            }
            for worker in sorted(alive.keys())
        }
    }


@web_routes.get('/logout', name="logout")
async def logout(request):
    await check_authorized(request)
    nexturl = request.query.get('next', '/')
    response = web.HTTPFound(nexturl)
    await forget(request, response)
    return response


@web_routes.get('/auth/github', name="login")
async def auth_github(request):
    logger.error("auth github with params %s", request.query)
    session = await get_session(request)
    nexturl = request.query.get('next', '/')
    baseurl = "http://ehome.hopto.org:8000/auth/github?next="+nexturl
    try:
        ghappapi = request.app['ghappapi']
        ghapi = await ghappapi.oauth_github_user(baseurl, session, request.query)
        if ghapi.username:
            await remember(request, web.HTTPFound(nexturl), ghapi.token)
            return web.HTTPFound(nexturl)
    except web.HTTPFound:
        raise
    except Exception as exc:
        logger.exception("failed to auth")
    return web.HTTPUnauthorized(body="Could not authenticate your Github account")
