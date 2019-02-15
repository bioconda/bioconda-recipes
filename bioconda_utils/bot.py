"""Bioconda Bot"""

import abc
import asyncio
import logging
import os
import re
import subprocess
import time
from typing import Dict, Callable
from functools import wraps

import aiohttp
from aiohttp import web
from celery import Celery
from celery import Task as _Task
from celery.signals import worker_process_init
import gidgethub.routing

from . import utils
from . import __version__ as VERSION
from .githubhandler import GitHubAppHandler, Event
from .githandler import TempGitHandler
from .recipe import Recipe

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

event_routes = gidgethub.routing.Router()  # pylint: disable=invalid-name
web_routes = web.RouteTableDef()  # pylint: disable=invalid-name


BOT_NAME = "BiocondaBot"
BOT_ALIAS_RE = re.compile(r'@bioconda[- ]?bot', re.IGNORECASE)
BOT_EMAIL = "47040946+BiocondaBot@users.noreply.github.com"


class Task(_Task):
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
    ghapi: GitHubAppHandler = None

    #: Stores the async run method when the sync run wrapper is installed
    _async_run = None

    def __call__(self, *args, **kwargs):
        """Intercept call to task"""
        logger.error("Calling %s(%s %s)", self.name, args, kwargs)
        super().__call__(*args, **kwargs)

    def bind(self, app=None):
        """Intercept binding of task to (celery) app

        Here we take the half-finished generated Task class and
        replace the async run method with a sync run method that
        executes the original method inside the asyncio loop.
        """
        if asyncio.iscoroutinefunction(self.run):
            @wraps(self.run)
            def sync_run(*args, **kwargs):
                self.loop.run_until_complete(self._async_run(*args, **kwargs))
            self._async_run, self.run = self.run, sync_run

            if not self.loop.is_running():
                self.loop.run_until_complete(self.async_init())
        super().bind(app)

    async def async_init(self):
        """Init things that need to be run inside the loop"""
        if not self.ghapi:
            self.ghapi = init_githubhandler(aiohttp.ClientSession())

    @abc.abstractmethod
    def run(self, *args, **kwargs):
        """The tasks actual run method."""

    @property
    def loop(self):
        """Get the async loop - creating a new one if necessary"""
        try:
            return asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            return loop


@worker_process_init.connect
def worker_process_init(**kwargs):
    logger.error("Started new worker: kwargs=%s", kwargs)


celery = Celery(task_cls=Task)  # pylint: disable=invalid-name

# Celery must be configured at module level to catch worker as well
# Settings are suggestions from CloudAMPQ
celery.conf.update(
    broker_url=os.environ.get('CLOUDAMQP_URL'),
    broker_pool_limit=2,  # need two so we can inspect
    broker_heartbeat=None,
    broker_connection_timeout=30,
    result_backend=None,
    event_queue_expires=60,
    worker_prefetch_multiplier=1,
    worker_concurrency=1
)


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


@celery.task(acks_late=True)
def sleep(seconds, msg):
    """Demo task that just sleeps for a given number of seconds"""
    logger.info("Sleeping for %i seconds: %s", seconds, msg)
    for second in range(seconds):
        time.sleep(1)
        logger.info("Slept for %i seconds: %s", second, msg)
    logger.info("Waking: %s", msg)


@command_routes.register("sleep")
async def command_sleep(_event, _ghapi, *args):
    """Another demo command. This one triggers the sleep task via celery"""
    sleep.apply_async((20, args[0]))


@celery.task(bind=True, acks_late=True)
async def bump(self: Task, installation, user, repo, ref, recipes):
    """Bump the build number in each recipe"""
    logger.info("Processing bump command")
    logger.info("  User=%s Repo=%s Ref=%s Recipes=%s", user, repo, ref, recipes)
    token = await self.ghapi.get_installation_token(installation)
    git = TempGitHandler(password=token,
                         fork=user + "/" + repo)
    git.set_user(BOT_NAME, BOT_EMAIL)
    cwd = os.getcwd()

    os.chdir(git.tempdir.name)
    branch = git.create_local_branch(ref)
    branch.checkout()
    for meta_fn in recipes:
        recipe_dir = os.path.dirname(meta_fn)
        recipe_folder = os.path.dirname(recipe_dir)
        recipe = Recipe(recipe_dir, recipe_folder)
        logger.info("Reading %s", meta_fn)
        with open(meta_fn) as fdes:
            data = fdes.read()
        recipe.load_from_string(data)
        buildno = int(recipe.meta['build']['number']) + 1
        recipe.reset_buildnumber(buildno)
        with open(meta_fn, "w") as out:
            out.write(recipe.dump())
    msg = f"Bump {recipe} buildno to {buildno}"
    if not git.commit_and_push_changes(recipes, ref, msg, sign=True):
        logger.error("Failed to push?!")

    os.chdir(cwd)
    git.close()

@command_routes.register("bump")
async def command_bump(event, ghapi, *args):
    """Bump the build number of a recipe

    This needs to know which repo/branch to operate on and which
    recipe to bump.

    If we are on a PR, we commit to the repo/branch from which the PR
    is coming. We inspect the PR to see which recipe's where changed,
    if there is only one, it becomes the default.

    If we can't determine what and where to bump, post an error comment.
    """
    logger.info("Got bump command: %s", args)

    user = ref = repo = None

    issue_number = int(event.get('issue/number'))

    # Determine user/repo/ref
    if 'pull_request' in event.get('issue'):
        prs = await ghapi.get_prs(number=issue_number)
        user = prs['head']['user']['login']
        repo = prs['head']['repo']['name']
        ref = prs['head']['ref']
        logger.info("Bumping: %s/%s:%s", user, repo, ref)

        files = await ghapi.get_pr_modified_files(number=issue_number)
        recipes = [item['filename'] for item in files
                   if item['filename'].endswith('/meta.yaml')]
    else:
        logger.error("Can't bump in %i - not a PR", issue_number)
        await ghapi.create_comment(issue_number, "I can only do this from a PR")
        return

    if not recipes:
        await ghapi.create_comment(issue_number, "Which recipe? This PR does not seem to modif any")
        return

    if len(recipes) > 1:
        await ghapi.create_comment(issue_number, "This PR modifies multiple recipes.")

    installation = event.get('installation/id')
    bump.apply_async((installation, user, repo, ref, recipes))


@event_routes.register("issue_comment", action="created")
async def comment_created(event, ghapi, *args, **_kwargs):
    """Dispatches @bioconda-bot commands

    This function watches for comments on issues. Lines starting with
    an @mention of the bot are considered commands and dispatched.
    """
    commands = [
        line.lower().split()[1:]
        for line in event.data['comment']['body'].splitlines()
        if BOT_ALIAS_RE.match(line)
    ]
    if not commands:
        logger.info("No command in comment")
    for cmd, *args in commands:
        logger.info("Dispatching %s - %s", cmd, args)
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
        for worker in worker_status.ping().keys():
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


def init_celery(app, loglevel):
    """Launches celery worker and sets up teardown procedures"""
    proc = subprocess.Popen([
        'celery',
        '-A', 'bioconda_utils.bot',
        'worker',
        '-l', loglevel,
        '--without-heartbeat',
        '-c', '1',
    ])
    app['celery_worker'] = proc
    async def collect_worker(app):
        logger.info("Terminating worker: sending shutdown")
        celery.control.broadcast('shutdown')
        proc = app['celery_worker']
        wait = 10
        if proc.poll() is None:
            for second in range(wait):
                logger.info("Terminating worker: waiting %i/%i", second, wait)
                time.sleep(1)
                if proc.poll() is not None:
                    break
            else:
                logger.info("Terminating worker: failed. Sending kill signal")
                proc.kill()
        logger.info("Terminating worker: collecting process")
        app['celery_worker'].wait()
        logger.info("Terminating worker: done")

    app.on_shutdown.append(collect_worker)


def init_githubhandler(session):
    """Prepare Github API Handler"""
    app_key = os.environ.get("APP_KEY_PEM")
    if not app_key:
        raise ValueError("Environment variable APP_KEY_PEM empty or not set")
    app_id = os.environ.get("APP_ID")
    if not app_id:
        raise ValueError("Environment variable APP_ID empty or not set")
    return GitHubAppHandler(session, BOT_NAME, app_key, app_id)


def init_gpg():
    """Install GPG key from environment"""
    gpg_key = os.environ.get("GPG_KEY")
    if not gpg_key:
        raise ValueError("Envionment variable GPG_KEY empty or not set")
    proc = subprocess.run(['gpg', '--import'],
                          input=gpg_key, stderr=subprocess.PIPE,
                          encoding='ascii', check=True)
    for line in proc.stderr.splitlines():
        match = re.match(r'gpg: key ([\dA-F]{16}): secret key imported', line)
        if match:
            key = match.group(1)
            break
    else:
        raise ValueError(f"Unable to import GPG key: {proc.stderr}")
    return key


async def init_app():
    """Initialize App

    This function is the entry point for wrappers that take an app factory
    as argument, notably gunicorn:

    $ gunicorn bioconda_utils.bot:init_app \
      --worker-class aiohttp.worker.GunicornWebWorker \
      --reload
    """

    loglevel = 'INFO'
    utils.setup_logger('bioconda_utils', loglevel, prefix="")
    logger.info("Starting bot (version=%s)", VERSION)

    _gpg_key = init_gpg()

    app = web.Application()

    # Prepare persistent client session
    app['client_session'] = aiohttp.ClientSession()
    async def close_session(app):
        await app['client_session'].close()
    app.on_shutdown.append(close_session)

    app['ghapi'] = init_githubhandler(app['client_session'])

    # Add routes collected above
    app.add_routes(web_routes)

    init_celery(app, loglevel)

    return app


def run_app(port):
    """Runs the bot app locally on **port**"""
    web.run_app(init_app(), port=port)
