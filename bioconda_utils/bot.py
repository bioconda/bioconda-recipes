"""Bioconda Bot"""

import abc
import asyncio
import logging
import os
import re
import subprocess
import time
from collections import namedtuple
from typing import Dict, Callable, Optional
from functools import wraps

import aiohttp
from aiohttp import web
from celery import Celery
from celery import Task as _Task
from celery.signals import worker_process_init, celery_init
import gidgethub.routing

from . import utils
from . import __version__ as VERSION
from .githubhandler import GitHubAppHandler, GitHubHandler, Event
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
    ghapi: GitHubHandler = None

    #: Access Github App API
    ghappapi: GitHubAppHandler = None

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
                self.loop.run_until_complete(self.async_pre_run(args, kwargs))
                self.loop.run_until_complete(self._async_run(*args, **kwargs))
            self._async_run, self.run = self.run, sync_run

            if not self.loop.is_running():
                self.loop.run_until_complete(self.async_init())
        super().bind(app)

    async def async_pre_run(self, args, kwargs):
        ghapi_data = kwargs.get('ghapi_data')
        self.ghapi = await self.ghappapi.get_github_api(**ghapi_data)

    async def async_init(self):
        """Init things that need to be run inside the loop"""
        if not self.ghappapi:
            self.ghappapi = init_githubhandler(aiohttp.ClientSession())

    def schedule(self, *args, ghapi=None, **kwargs):
        return self.delay(*args,
                          ghapi_data=ghapi.to_dict() if ghapi else None,
                          **kwargs)

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
def setup_new_worker_process(**kwargs):
    logger.error("Started new worker: kwargs=%s", kwargs)


@celeryd_init.connect
def setup_new_celery_process(sender=None, conf=None, **kwargs):
    init_gpg()


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


PRInfo = namedtuple('PRInfo', 'installation user repo ref recipes issue_number')


async def get_pr_info(ghapi, event) -> Optional[PRInfo]:
    issue_number = int(event.get('issue/number'))
    if 'pull_request' not in event.get('issue'):
        logger.error("Issue %s is not a PR", issue_number)
        await ghapi.create_comment(issue_number, "I can only do this from a PR")
        return None
    prs = await ghapi.get_prs(number=issue_number)
    user = prs['head']['user']['login']
    repo = prs['head']['repo']['name']
    ref = prs['head']['ref']

    files = await ghapi.get_pr_modified_files(number=issue_number)
    recipes = [item['filename'] for item in files
               if item['filename'].endswith('/meta.yaml')]
    if not recipes:
        await ghapi.create_comment(issue_number, "This PR does not modify any recipes")
        return None

    installation = event.get('installation/id')
    return PRInfo(installation, user, repo, ref, recipes, issue_number)


class PrBranch:
    def __init__(self, ghappapi, pr_info):
        self.ghappapi = ghappapi
        self.pr_info = pr_info
        self.cwd = None
        self.git = None

    async def __aenter__(self):
        token = await self.ghappapi.get_installation_token(self.pr_info.installation)
        self.git = TempGitHandler(password=token,
                                  fork=self.pr_info.user + "/" + self.pr_info.repo)
        self.git.set_user(BOT_NAME, BOT_EMAIL)

        self.cwd = os.getcwd()
        os.chdir(self.git.tempdir.name)

        branch = self.git.create_local_branch(self.pr_info.ref)
        branch.checkout()
        return self.git

    async def __aexit__(self, exc_type, exc, tb):
        os.chdir(self.cwd)
        self.git.close()


@celery.task(bind=True, acks_late=True)
async def bump(self: "Task", pr_info_dict: "Dict", ghapi_data=None):
    """Bump the build number in each recipe"""
    pr_info = PRInfo(**pr_info_dict)
    logger.info("Processing bump command: %s", pr_info)
    async with PrBranch(self.ghappapi, pr_info) as git:
        for meta_fn in pr_info.recipes:
            recipe = Recipe.from_file('recipes', meta_fn)
            buildno = int(recipe.meta['build']['number']) + 1
            recipe.reset_buildnumber(buildno)
            recipe.save()
        msg = f"Bump {recipe} buildno to {buildno}"
        if not git.commit_and_push_changes(pr_info.recipes, pr_info.ref, msg, sign=True):
            logger.error("Failed to push?!")


@command_routes.register("bump")
async def command_bump(event, ghapi, *args):
    """Bump the build number of a recipe    """
    logger.info("Got bump command: %s", args)
    pr_info = await get_pr_info(ghapi, event)
    if pr_info:
        bump.schedule(pr_info, ghapi=ghapi)


@celery.task(bind=True, acks_late=True)
async def lint(self: "Task", pr_info_dict: "Dict", ghapi_data=None):
    """Lint each recipe"""
    pr_info = PRInfo(**pr_info_dict)
    logger.info("Processing lint command: %s", pr_info)

    async with PrBranch(self.ghappapi, pr_info) as git:
        utils.load_config('config.yml')
        from bioconda_utils.linting import lint, LintArgs, markdown_report;
        recipes = [r[:-len('/meta.yaml')] for r in pr_info.recipes]
        df = lint(recipes, LintArgs())
        msg = markdown_report(df)
        await self.ghapi.create_comment(pr_info.issue_number, msg)
    utils.RepoData()._df = None


@command_routes.register("lint")
async def command_lint(event, ghapi, *args):
    """Lint the current recipe"""
    logger.info("Got lint command: %s", args)
    pr_info = await get_pr_info(ghapi, event)
    if pr_info:
        lint.schedule(pr_info, ghapi=ghapi)


@command_routes.register("autobump")
async def command_autobump(event, ghapi, *args):
    """Run autobump on the listed recipes"""
    logger.info("Got autobump command: %s", args)


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


def get_secret(name):
    try:
        with open(os.environ[name + "_FILE"]) as secret_file:
            return secret_file.read()
    except (FileNotFoundError, PermissionError, KeyError):
        try:
            return os.environ[name]
        except KeyError:
            raise ValueError(
                f"Missing secrets: configure {name} or {name}_FILE to contain or point at secret"
            ) from None


def init_githubhandler(session):
    """Prepare Github API Handler"""
    app_key = get_secret("APP_KEY")
    app_id = get_secret("APP_ID")
    return GitHubAppHandler(session, BOT_NAME, app_key, app_id)


def init_gpg():
    """Install GPG key from environment"""
    gpg_key = get_secret("CODE_SIGNING_KEY")
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


async def init_app(disable_internal_celery=True):
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

    app['ghappapi'] = init_githubhandler(app['client_session'])

    # Add routes collected above
    app.add_routes(web_routes)

    if not disable_internal_celery:
        init_celery(app, loglevel)

    return app


def run_app(port):
    """Runs the bot app locally on **port**"""
    web.run_app(init_app(), port=port)
