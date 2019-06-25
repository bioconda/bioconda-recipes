"""
HTTP Views (accepts and parses webhooks)
"""

import logging

from aiohttp import web
from aiohttp_session import get_session
from aiohttp_security import check_authorized, forget, permits, remember, authorized_userid
from aiohttp_jinja2 import template, render_template

from .events import event_routes
from ..githubhandler import Event
from ..circleci import SlackMessage
from .worker import capp
from .config import APP_SECRET, BOT_BASEURL

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

#: List of routes from url path to handler defined in this module
web_routes = web.RouteTableDef()  # pylint: disable=invalid-name

#: List of navigation bar entries defined by this module
navigation_bar = []  # pylint: disable=invalid-name


def add_to_navbar(title):
    """Decorator adding a view to the navigation bar

    Must be "above" the ``@web_routes`` decorator.

    Arguments:
      title: Title to register for this page. Will be the HTML title
             and the name in the navbar.

    """
    def wrapper(func):
        route = web_routes[-1]
        navigation_bar.append((route.path, route.kwargs['name'], title))
        return func
    return wrapper


async def check_permission(request, permission, context=None):
    """Checks permissions

    Custom implementation replacing aiohttp-security one. This one
    adds the requested permissions to the request so they can
    be presented in the error handler.

    Raises:
      HTTPForbidden
    """

    await check_authorized(request)
    allowed = await permits(request, permission, context)
    if not allowed:
        request['permission_required'] = permission
        raise web.HTTPForbidden()


@web_routes.post('/_gh')
async def github_webhook_dispatch(request):
    """View for incoming webhooks from Github

    Here, webhooks (events) from Github are accepted and dispatched to
    the event handlers defined in `events` module and registered with
    `event_routes`.

    """
    try:
        body = await request.read()
        secret = APP_SECRET
        if secret == "IGNORE":
            # For debugging locally, we allow not verifying the
            # secret normally used to authenticate incoming webhooks.
            # You do have to set it to "IGNORE" so that it's not
            # accidentally disabled.
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

        # Remember the rate limit
        # FIXME: remove this, we have many tokens in many places, this no longer works sensibly.
        request.app['gh_rate_limit'] = ghapi.rate_limit

        return web.Response(status=200)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Failure in webhook dispatch")
        return web.Response(status=500)


@web_routes.post('/hooks/circleci')
async def generic_circleci_dispatch(request):
    """View for incoming webhooks from CircleCI

    These are actually slack messages. We try to deparse them, but
    nothing is implemented on acting upon them yet.

    """
    try:
        body = await request.read()
        msg = SlackMessage(request.headers, body)
        logger.info("Got data from Circle: %s", msg)
        return web.Response(status=200)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Failure in circle webhook dispatch")
        return web.Response(status=500)


@web_routes.post('/hooks/{source}')
async def generic_webhook_dispatch(request):
    """View for all other incoming webhooks

    This is just for debugging, so we can see what we would be
    receiving

    """
    try:
        source = request.match_info['source']
        body = await request.read()
        logger.error("Got generic webhook for %s", source)
        logger.error("   Data: %s", body)
        return web.Response(status=200)
    except Exception: # pylint: disable=broad-except
        logger.exception("Failure in generic webhook dispatch")
        return web.Response(status=500)


@add_to_navbar(title="Home")
@web_routes.get("/", name="home")
@template('bot_index.html')
async def show_index(_request):
    """View for the Bot's home page.

    Renders nothing special at the moment, just the template.

    """
    return {}


@add_to_navbar(title="Status")
@web_routes.get("/status", name="status")
@template("bot_status.html")
async def show_status(request):
    """View for checking in on the bots status

    Shows the status of each responsding worker.  This page may take
    100ms extra to render. If workers are busy, they may not respons
    within that time.

    """
    await check_permission(request, 'bioconda')
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
    """View for logging out user

    Accepts a **next** parameter in the URL. This is where the user is
    sent back to (via HTTP redirect) after logging out.

    """
    await check_authorized(request)
    nexturl = request.query.get('next', '/')
    response = web.HTTPFound(nexturl)
    await forget(request, response)
    return response


@web_routes.get('/login')
async def login(request):
    """View for login page

    Redirects to ``/auth/github`` in all cases - no other login
    methods supported.

    """
    return web.HTTPFound('/auth/github')


@web_routes.get('/auth/github', name="login")
async def auth_github(request):
    """View for signing in with Github

    Currently the only authentication method (and probably will remain so).

    This will redirect to Github to allow OAUTH authentication if
    necessary.

    """
    session = await get_session(request)
    nexturl = request.query.get('next') or '/'
    baseurl = BOT_BASEURL + "/auth/github?next=" + nexturl
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
