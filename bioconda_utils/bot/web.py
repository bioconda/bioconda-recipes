"""Bioconda Bot"""

import logging
import subprocess
import time

import aiohttp

from .config import BOT_NAME, APP_KEY, APP_ID
from .views import web_routes
from .. import utils
from ..githubhandler import GitHubAppHandler
from .. import __version__ as VERSION


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name
loglevel = 'INFO'


async def start():
    """Initialize App

    This function is the entry point for wrappers that take an app factory
    as argument, notably gunicorn:

    $ gunicorn bioconda_utils.bot:init_app \
      --worker-class aiohttp.worker.GunicornWebWorker \
      --reload
    """
    utils.setup_logger('bioconda_utils', loglevel, prefix="")
    logger.info("Starting bot (version=%s)", VERSION)

    app = aiohttp.web.Application()

    # Prepare persistent client session
    app['client_session'] = aiohttp.ClientSession()
    async def close_session(app):
        await app['client_session'].close()
    app.on_shutdown.append(close_session)

    app['ghappapi'] = GitHubAppHandler(app['client_session'],
                                       BOT_NAME, APP_KEY, APP_ID)

    # Add routes collected above
    app.add_routes(web_routes)

    return app


async def start_with_celery():
    """Initialize app and launch internal celery worker

    This isn't simply a flag for `init_app` because async app factories
    cannot (easily) receive parameters from the gunicorn commandline.
    """
    app = await start()

    proc = subprocess.Popen([
        'celery',
        '-A', 'bioconda_utils.bot.worker',
        'worker',
        '-l', loglevel,
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

