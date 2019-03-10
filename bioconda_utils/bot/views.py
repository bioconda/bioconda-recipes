"""
HTTP Views (pages)
"""

import logging

from aiohttp import web

from .events import event_routes
from ..githubhandler import Event
from .. import __version__ as VERSION
from .worker import celery

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name
web_routes = web.RouteTableDef()  # pylint: disable=invalid-name


@web_routes.post('/_gh')
async def webhook_dispatch(request):
    """Accepts webhooks from Github and dispatches them to event handlers"""
    try:
        body = await request.read()
        event = Event.from_http(request.headers, body)
        logger.info('GH delivery ID %s', event.delivery_id)

        # Respond to liveness check
        if event.event == "ping":
            return web.Response(status=200)

        ghapi = await request.app['ghappapi'].get_github_api(
            dry_run=False,
            installation=event.get('installation/id'),
            to_user=event.get('repository/owner/login'),
            to_repo=event.get('repository/name')
        )
        try:
            await event_routes.dispatch(event, ghapi)
        except Exception:  # pylint: disable=broad-except
            logger.exception("Failed to dispatch %s", event.delivery_id)
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
        logger.info("Status: getting celery data")
        msg = f"""
        Running version {VERSION}

        {request.app.get('gh_rate_limit')}

        """
        worker_status = celery.control.inspect(timeout=0.1)
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
