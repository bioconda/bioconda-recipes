"""
HTTP Views (accepts and parses webhooks)
"""

import logging

from aiohttp import web

from .events import event_routes
from ..githubhandler import Event
from .. import __version__ as VERSION
from .worker import celery
from .config import APP_SECRET

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name
web_routes = web.RouteTableDef()  # pylint: disable=invalid-name


@web_routes.post('/_gh')
async def webhook_dispatch(request):
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


@web_routes.get("/")
async def show_status(request):
    """Shows the index page

    This is rendered at eg https://bioconda.herokuapps.com/
    """
    try:
        logger.info("Status: getting celery data")
        msg = f"""
        Running version {VERSION}

        {request.app.get('gh_rate_limit')}

        """
        worker_status = celery.control.inspect(timeout=0.1)
        if not worker_status:
            msg += """
            no workers online
            """
        else:
            for worker in sorted(worker_status.ping().keys()):
                active = worker_status.active(worker)
                reserved = worker_status.reserved(worker)
                msg += f"""
                Worker: {worker}
                active: {len(active[worker])}
                queued: {len(reserved[worker])}
                """
        return web.Response(text=msg)
    except Exception:  # pylint: disable=broad-except
        logger.exception("Failure in show status")
        return web.Response(status=500)
