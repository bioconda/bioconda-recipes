"""
Celery Worker
"""

import abc
import asyncio
import logging
import os
import re
import time
from functools import wraps
import subprocess
from typing import TYPE_CHECKING
from importlib import import_module

import aiohttp

from celery import Celery, Task
from celery.signals import celeryd_init

from kombu import serialization
import simplejson

from ..githubhandler import GitHubAppHandler, GitHubHandler
from .config import APP_ID, APP_KEY, CODE_SIGNING_KEY, BOT_NAME

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class AsyncTask(Task):
    """Task class with support for async tasks

    We override celery.Task with our own version, with some extra
    features and defaults:

    - Since we already use a lot of async stuff elsewhere, it's useful
      to allow the ``run`` method of tasks be ``async``. This Task
      class detects if the method provided is a coroutine and runs it
      inside the asyncio event loop.

      >>> @app.task()
      >>> async def mytask(self, bind=True):
      >>>    await self.async_init()
      >>>    ...

    - Provide access to a GitHubAppHandler instance shared at least
      within the worker process.

      This is a little tedious. Since the task may be spawned some
      time after the webook that created it was triggered, the tokens
      we got inside the webserver may have timed out. In an attempt to
      avoid wasting API calls to create those tokens continuously, the
      Task class maintains a copy.

    - Default to `acks_late = True`. The reason we use Celery at all
      is so that spawned tasks can survive a shutdown of the app.

    """
    #: Our tasks should be re-run if they don't finish
    acks_late = True

    #: Access the Github API
    ghapi: "GitHubHandler" = None

    #: Access Github App API
    ghappapi: "GitHubAppHandler" = None

    #: Stores the async run method when the sync run wrapper is installed
    _async_run = None

    def bind(self, app=None):
        """Intercept binding of task to (celery) app

        Here we take the half-finished generated Task class and
        replace the async run method with a sync run method that
        executes the original method inside the asyncio loop.
        """
        if asyncio.iscoroutinefunction(self.run):  # only for async funcs
            @wraps(self.run)
            def sync_run(*args, **kwargs):
                args = list(args)
                self.loop.run_until_complete(self.async_pre_run(args, kwargs))
                return self.loop.run_until_complete(self._async_run(*args, **kwargs))

            # swap run method with wrapper defined above
            self._async_run, self.run = self.run, sync_run

            if not self.loop.is_running():
                self.loop.run_until_complete(self.async_init())
        super().bind(app)

    async def async_init(self):
        """Init things that need to be run inside the loop

        This happens during binding -> on load.
        """
        if not self.ghappapi:
            self.ghappapi = GitHubAppHandler(aiohttp.ClientSession(), BOT_NAME,
                                             APP_KEY, APP_ID)

    async def async_pre_run(self, args, kwargs):
        """Per-call async initialization

        Prepares the `ghapi` property for tasks using ghapi_data added
        to arguments via `schedule()`.

        FIXME: doesn't replace kwargs
        """
        for num, arg in enumerate(args):
            if isinstance(arg, GitHubHandler):
                args[num] = await self.ghappapi.get_github_api(
                    False, arg.user, arg.repo,
                    arg.installation)

    @abc.abstractmethod
    def run(self, *args, **kwargs):
        """The tasks actual run method. Will be replaced during bind"""

    @property
    def loop(self):
        """Get the async loop - creating a new one if necessary"""
        try:
            return asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            return loop


def custom_dumps(s):
    """Serialize **s** to JSON accepting **for_json** serializer method"""
    return simplejson.dumps(s, for_json=True)


def custom_loads(s):
    """Deserialize **s** recreating objects

    JSON objects (dicts) containing a __type__ and a __module__
    field are turned into objects by loading and instantiating
    the type, passing the result dict from obj.for_json() to
    __init__().
    """
    def decode(obj):
        if isinstance(obj, dict):
            try:
                typ = obj.pop('__type__')
                mod = import_module(obj.pop('__module__'))
                klass = getattr(mod, typ)
                return klass(**obj)
            except KeyError:
                    pass
        return obj
    return simplejson.loads(s, object_hook=decode)

# Register a custom serializer. We do this so we can conveniently
# transfer objects without resorting to pickling.
serialization.register('custom_json',
                       custom_dumps, custom_loads,
                       content_type='application/x-bioconda-json',
                       content_encoding='utf8')


# Instantiate Celery app, setting our AsyncTask as default
# task class and loading the tasks from tasks.py
celery = Celery(
    task_cls=AsyncTask,
    include=['bioconda_utils.bot.tasks']
)  # pylint: disable=invalid-name


# Celery must be configured at module level to catch worker as well
# Settings are suggestions from CloudAMPQ
celery.conf.update(
    # Set the URL to the AMQP broker using environment variable
    broker_url=os.environ.get('CLOUDAMQP_URL'),

    # Limit the number of connections to the pool. This should
    # be 2 when running on Heroku to avoid running out of free
    # connections on CloudAMPQ.
    #
    # broker_pool_limit=2,  # need two so we can inspect

    broker_heartbeat=None,
    broker_connection_timeout=30,

    # We don't feed back our tasks results
    result_backend='rpc://',
    event_queue_expires=60,
    worker_prefetch_multiplier=1,
    worker_concurrency=1,
    task_serializer = 'custom_json',
    accept_content = ['custom_json', 'json']
    #task_acks_late=true
)


@celeryd_init.connect
def setup_new_celery_process(sender=None, conf=None, **kwargs):
    """This hook is called when a celery worker is initialized

    Here we make sure that the GPG signing key is installed
    """
    install_gpg_key()


def install_gpg_key():
    """Install GPG key from environment"""
    proc = subprocess.run(['gpg', '--import'],
                          input=CODE_SIGNING_KEY, stderr=subprocess.PIPE,
                          encoding='ascii', check=True)
    for line in proc.stderr.splitlines():
        match = re.match(r'gpg: key ([\dA-F]{16}): secret key imported', line)
        if match:
            key = match.group(1)
            break
    else:
        raise ValueError(f"Unable to import GPG key: {proc.stderr}")
    return key
