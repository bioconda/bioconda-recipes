"""AioHTTP Web Server Setup"""

import logging
import subprocess
import time
import os

import base64
from cryptography import fernet
import aiohttp
import aiohttp_jinja2
import jinja2
import markdown
import markupsafe
from aiohttp_session import setup as setup_session
from aiohttp_session.cookie_storage import EncryptedCookieStorage
from aiohttp_security import (authorized_userid,
                              setup as setup_security,
                              SessionIdentityPolicy, AbstractAuthorizationPolicy)
from .config import (BOT_NAME, APP_KEY, APP_ID, GITTER_TOKEN, GITTER_CHANNELS,
                     APP_CLIENT_ID, APP_CLIENT_SECRET)
from .views import web_routes, navigation_bar
from .chat import GitterListener
from .. import utils
from ..githubhandler import GitHubAppHandler, AiohttpGitHubHandler
from .. import __version__ as VERSION


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

#: Override this to get more verbose logging of web app (and, if launched
#: with web frontend, the worker).
LOGLEVEL = 'INFO'


class AuthorizationPolicy(AbstractAuthorizationPolicy):
    """Authorization policy for web interface"""
    def __init__(self, app):
        self.app = app

    async def authorized_userid(self, identity: str) -> AiohttpGitHubHandler:
        """Retrieve authorized user id.

        Arguments:
          identity: random string identifying user. We use bearer token.
        Returns:
          Logged in Github API client.
        """
        return await self.app['ghappapi'].get_github_user_api(identity)

    async def permits(self, identity: str, permission: str, context=None) -> bool:
        """Check user permissions.

        Returns:
          True if the **identity** is allowed the **permission**
          in the current **context**.
        """
        # Fail if no identity
        if identity is None:
            return False

        org, _, team = permission.partition('/')

        # Fail if no permissions requested
        if not org:
            logger.error("Internal error: checking for empty permission not allowed")
            return False

        # Fail if not logged in
        userapi = await self.app['ghappapi'].get_github_user_api(identity)
        if not userapi:
            return False

        # Fail if not in requested org
        if org not in await userapi.get_user_orgs():
            return False

        # Fail if team requested and user not in team
        if team and not await userapi.is_team_member(userapi.username, team):
            return False

        return True


async def jinja_defaults(request):
    """Provides all web views using aiohttp-jinja2 with default values

    Values are:
      - **user**: The `AiohttpGitHubHandler for the user if a user is logged in.
      - **version**: The version of the bot running
      - **navigation_bar**: List of 3-tuples for building nav bar. Each tuple
        comprises the location, ID and natural name for the page to be added
        to the main nav bar.
      - **active_page**: The ID of the currently rendered page. This is set in
        the aiohttp router as ``name`` field.
      - **title**: The title of the current page. Parsed from **navigation_bar**
        using **active_page**.
    """
    active_page = request.match_info.route.name
    try:
        title = next(item for item in navigation_bar if item[1] == active_page)[2]
    except StopIteration:
        title = 'Unknown'
    ghapi = await authorized_userid(request)
    return {
        'user': ghapi,
        'version': VERSION,
        'navigation_bar': navigation_bar,
        'active_page': active_page,
        'title': title,
        'request': request,
    }


md2html = markdown.Markdown(extensions=[
    'markdown.extensions.fenced_code',
    'markdown.extensions.tables',
    'markdown.extensions.admonition',
    'markdown.extensions.codehilite',
    'markdown.extensions.sane_lists',
])

def jinja2_filter_markdown(text):
    return markupsafe.Markup(md2html.reset().convert(text))


@aiohttp.web.middleware
async def handle_errors(request, handler):
    try:
        return await handler(request)
    except aiohttp.web.HTTPException as exc:
        if exc.status in (302,):
            raise
        try:
            return aiohttp_jinja2.render_template('bot_40x.html', request, {'exc':exc})
        except KeyError as XYZ:
            raise exc

async def start():
    """Initialize App

    This function is the entry point for wrappers that take an app factory
    as argument, notably gunicorn:

    $ gunicorn bioconda_utils.bot:init_app \
      --worker-class aiohttp.worker.GunicornWebWorker \
      --reload
    """
    utils.setup_logger('bioconda_utils', LOGLEVEL, prefix="")
    logger.info("Starting bot (version=%s)", VERSION)

    app = aiohttp.web.Application()
    app['name'] = BOT_NAME

    # Set up session storage
    fernet_key = fernet.Fernet.generate_key()
    secret_key = base64.urlsafe_b64decode(fernet_key)
    session_store = EncryptedCookieStorage(secret_key)
    setup_session(app, session_store)

    # Set up security
    setup_security(app, SessionIdentityPolicy(), AuthorizationPolicy(app))

    # Set up jinja2 rendering
    loader = jinja2.PackageLoader('bioconda_utils', 'templates')
    aiohttp_jinja2.setup(app, loader=loader,
                         context_processors=[jinja_defaults],
                         filters={'markdown': jinja2_filter_markdown})

    # Set up error handlers
    app.middlewares.append(handle_errors)

    # Prepare persistent client session
    app['client_session'] = aiohttp.ClientSession()

    # Create Github client
    app['ghappapi'] = GitHubAppHandler(app['client_session'],
                                       BOT_NAME, APP_KEY, APP_ID,
                                       APP_CLIENT_ID, APP_CLIENT_SECRET)

    # Create Gitter Client (background process)
    app['gitter_listener'] = GitterListener(
        app, GITTER_TOKEN, GITTER_CHANNELS, app['client_session'],
        app['ghappapi'])

    # Add routes collected above
    app.add_routes(web_routes)

    # Set up static files
    utils_path = os.path.dirname(os.path.dirname(__file__))
    app.router.add_static("/css", os.path.join(utils_path, 'templates/css'))

    # Close session - this needs to be at the end of the
    # on shutdown pieces so the client session remains available
    # until everything is done.
    async def close_session(app):
        await app['client_session'].close()
    app.on_shutdown.append(close_session)

    return app


async def start_with_celery():
    """Initialize app and launch internal celery worker

    This isn't simply a flag for `start` because async app factories
    cannot (easily) receive parameters from the gunicorn commandline.
    """
    app = await start()

    proc = subprocess.Popen([
        'celery',
        '-A', 'bioconda_utils.bot.worker',
        'worker',
        '-l', LOGLEVEL,
        '--without-heartbeat',
        '-c', '1',
    ])
    app['celery_worker'] = proc
    async def collect_worker(app):
        # We don't use celery.broadcast('shutdown') as that seems to trigger
        # an immediate reload. Instead, just send a sigterm.
        proc = app['celery_worker']
        logger.info("Terminating celery worker: sending sigterm")
        proc.terminate()
        wait = 10
        if proc.poll() is None:
            for second in range(wait):
                logger.info("Terminating celery worker: waiting %i/%i", second, wait)
                time.sleep(1)
                if proc.poll() is not None:
                    break
            else:
                logger.info("Terminating celery worker: failed. Sending sigkill")
                proc.kill()
        logger.info("Terminating celery worker: collecting process")
        app['celery_worker'].wait()
        logger.info("Terminating celery worker: done")

    app.on_shutdown.append(collect_worker)

    return app
