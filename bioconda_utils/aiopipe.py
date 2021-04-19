"""Utilities for Asynchronous Processing"""

import abc
import asyncio
import logging
import os
import pickle
import signal

from concurrent.futures import ProcessPoolExecutor
try:
    from concurrent.futures import BrokenExecutor
except ImportError:
    # BrokenExecutor is new in Py3.7, 3.6 only has one of its
    # subclasses, the BrokenProcessPool RuntimeError.
    from concurrent.futures.process import BrokenProcessPool as BrokenExecutor

from hashlib import sha256
from urllib.parse import urlparse
from typing import Dict, Iterator, List, Generic, Optional, Type, TypeVar

import aiohttp
import aioftp
import backoff

from .utils import tqdm, threads_to_use


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


ITEM = TypeVar('ITEM')

class EndProcessing(BaseException):
    """Raised by `AsyncFilter` to tell `AsyncPipeline` to stop processing"""

class EndProcessingItem(Exception):
    """Raised to indicate that an item should not be processed further"""
    __slots__ = ['item', 'args']
    template = "broken: %s"
    level = logging.INFO

    def __init__(self, item: ITEM, *args) -> None:
        super().__init__(item, *args)
        self.item = item
        self.args = args

    def log(self, uselogger=logger, level=None):
        """Print message using provided logging func"""
        if not level:
            level = self.level
        uselogger.log(level, str(self.item) + " " + self.template, *self.args)

    def __str__(self):
        return (str(self.item) + " " + self.template) % tuple(self.args)

    @property
    def name(self):
        """Name of class"""
        return self.__class__.__name__


class AsyncFilter(abc.ABC, Generic[ITEM]):
    """Function object type called by Scanner"""
    def __init__(self, pipeline: "AsyncPipeline", *_args, **_kwargs) -> None:
        self.pipeline = pipeline

    @abc.abstractmethod
    async def apply(self, recipe: ITEM):
        """Process a recipe. Returns False if processing should stop"""

    async def async_init(self) -> None:
        """Called inside loop before processing"""

    def finalize(self) -> None:
        """Called at the end of a run"""


class AsyncPipeline(Generic[ITEM]):
    """Processes items in an asyncio pipeline"""

    def __init__(self, threads: int = None) -> None:
        try:  # get or create loop (threads don't have one)
            #: our asyncio loop
            self.loop = asyncio.get_event_loop()
        except RuntimeError:
            self.loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self.loop)
        #: number of threads to use
        self.threads = threads or threads_to_use()
        #: semaphore to limit io parallelism
        self.io_sem: asyncio.Semaphore = asyncio.Semaphore(1)
        #: must never run more than one conda at the same time
        #: (used by PyPi when running skeleton)
        self.conda_sem: asyncio.Semaphore = asyncio.Semaphore(1)
        #: the filters successively applied to each item
        self.filters: List[AsyncFilter] = []
        #: executor running things in separate python processes
        self.proc_pool_executor = ProcessPoolExecutor(self.threads)

        self._shutting_down = False

    def add(self, filt: Type[AsyncFilter[ITEM]], *args, **kwargs) -> None:
        """Adds `Filter` to this `Scanner`"""
        self.filters.append(filt(self, *args, **kwargs))

    async def shutdown(self, sig=None) -> None:
        self._shutting_down = True
        if sig == signal.SIGINT:
            logger.error("Ctrl-C pressed - aborting...")
        self.proc_pool_executor.shutdown()
        tasks = [t for t in asyncio.Task.all_tasks() if t != asyncio.Task.current_task()]
        for t in tasks:
            t.cancel()
        res_and_excs = await asyncio.gather(*tasks, return_exceptions=True)
        self.loop.stop()

    def run(self) -> bool:
        """Enters the asyncio loop and manages shutdown."""
        # We need to handle KeyboardInterrupt "manually" to get clean shutdown
        # for the ProcessPoolExecutor
        self.loop.add_signal_handler(signal.SIGINT,
                                     lambda: asyncio.ensure_future(self.shutdown(signal.SIGINT)))
        try:
            task = asyncio.ensure_future(self._async_run())
            self.loop.run_until_complete(task)
            logger.warning("Finished update")
        except asyncio.CancelledError:
            pass
        except EndProcessing:
            logger.error("Terminating...")
            self.loop.run_until_complete(self.shutdown())

        for filt in self.filters:
            filt.finalize()

    @abc.abstractmethod
    async def queue_items(self, send_q, return_q):
        pass

    def get_item_count(self) -> int:
        return 0

    async def _async_run(self) -> bool:
        """Runner within async loop"""
        # call init functions on filters
        await asyncio.gather(*(filt.async_init() for filt in self.filters))

        # setup queues
        source_q = asyncio.Queue()
        progress_q = asyncio.Queue()
        return_q = asyncio.Queue()

        # setup progress monitor
        tasks = []
        tasks.append(asyncio.ensure_future(self.show_progress(progress_q, return_q)))

        # setup workers
        tasks.extend(asyncio.ensure_future(self.worker(source_q, progress_q))
                     for n in range(self.threads))

        # send items
        await self.queue_items(source_q, return_q)

        # wait for all items done
        await source_q.join()
        await progress_q.join()
        await return_q.join()

        for task in tasks:
            task.cancel()
        try:
            await asyncio.gather(*tasks)
        except asyncio.CancelledError:
            pass

    async def show_progress(self, in_q, out_q) -> None:
        with tqdm(total=self.get_item_count()) as progress:
            while True:
                item = await in_q.get()
                progress.update(1)
                await out_q.put(item)
                in_q.task_done()

    async def worker(self, in_q, out_q) -> None:
        try:
            while True:
                item = await in_q.get()
                await self.process(item)
                await out_q.put(item)
                in_q.task_done()
        except asyncio.CancelledError:
            return

    async def process(self, item: ITEM) -> bool:
        """Applies the filters to an item"""
        try:
            for filt in self.filters:
                await filt.apply(item)
        except asyncio.CancelledError:
            raise
        except EndProcessingItem as item_error:
            item_error.log(logger)
            raise
        except BrokenExecutor:
            logger.exception("Fatal exception while processing %s", item)
            # can't fix this - if one of the pools is done for, so are we
            raise
        except Exception:  # pylint: disable=broad-except
            if not self._shutting_down:
                logger.exception("While processing %s", item)
            return False
        return True

    async def run_io(self, func, *args):
        """Run **func** in thread pool executor using **args**"""
        async with self.io_sem:
            return await self.loop.run_in_executor(None, func, *args)

    async def run_sp(self, func, *args):
        """Run **func** in process pool executor using **args**"""
        return await self.loop.run_in_executor(self.proc_pool_executor, func, *args)


class AsyncRequests():
    """Provides helpers for async access to URLs
    """

    #: Used as user agent in http requests and as requester in github API requests
    USER_AGENT = "bioconda/bioconda-utils"

    def __init__(self, cache_fn: str = None) -> None:
        #: aiohttp session (only exists while running)
        self.session: aiohttp.ClientSession = None
        self.cache_fn: str = cache_fn
        #: cache
        self.cache: Optional[Dict[str, Dict[str, str]]] = None

    async def __aenter__(self) -> 'AsyncRequests':
        session = aiohttp.ClientSession(headers={'User-Agent': self.USER_AGENT})
        await session.__aenter__()
        self.session = session
        if self.cache_fn:
            if os.path.exists(self.cache_fn):
                with open(self.cache_fn, "rb") as stream:
                    self.cache = pickle.load(stream)
            else:
                self.cache = {}
            if "url_text" not in self.cache:
                self.cache["url_text"] = {}
            if "url_checksum" not in self.cache:
                self.cache["url_checksum"] = {}
            if "ftp_list" not in self.cache:
                self.cache["ftp_list"] = {}
        return self

    async def __aexit__(self, ext_type, exc, trace):
        await self.session.__aexit__(ext_type, exc, trace)
        self.session = None
        if self.cache_fn:
            with open(self.cache_fn, "wb") as stream:
                pickle.dump(self.cache, stream)

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_text_from_url(self, url: str) -> str:
        """Fetch content at **url** and return as text

        - On non-permanent errors (429, 502, 503, 504), the GET is retried 10 times with
          increasing wait times according to fibonacci series.
        - Permanent errors raise a ClientResponseError
        """
        if self.cache and url in self.cache["url_text"]:
            return self.cache["url_text"][url]

        async with self.session.get(url) as resp:
            resp.raise_for_status()
            res = await resp.text()

        if self.cache:
            self.cache["url_text"][url] = res

        return res

    async def get_checksum_from_url(self, url: str, desc: str) -> str:
        """Compute sha256 checksum of content at **url**

        - Shows TQDM progress monitor with label **desc**.
        - Caches result
        """
        if self.cache and url in self.cache["url_checksum"]:
            return self.cache["url_checksum"][url]

        parsed = urlparse(url)
        if parsed.scheme in ("http", "https"):
            res = await self.get_checksum_from_http(url, desc)
        elif parsed.scheme == "ftp":
            res = await self.get_checksum_from_ftp(url, desc)

        if self.cache:
            self.cache["url_checksum"][url] = res

        return res

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_checksum_from_http(self, url: str, desc: str) -> str:
        """Compute sha256 checksum of content at http **url**

        Shows TQDM progress monitor with label **desc**.
        """
        checksum = sha256()
        async with self.session.get(url) as resp:
            resp.raise_for_status()
            size = int(resp.headers.get("Content-Length", 0))
            with tqdm(total=size, unit='B', unit_scale=True, unit_divisor=1024,
                      desc=desc, miniters=1, leave=False, disable=None) as progress:
                while True:
                    block = await resp.content.read(1024*1024)
                    if not block:
                        break
                    progress.update(len(block))
                    checksum.update(block)
        return checksum.hexdigest()

    @backoff.on_exception(backoff.fibo, aiohttp.ClientResponseError, max_tries=20,
                          giveup=lambda ex: ex.code not in [429, 502, 503, 504])
    async def get_file_from_url(self, fname: str, url: str, desc: str) -> None:
        """Fetch file at **url** into **fname**

        Shows TQDM progress monitor with label **desc**.
        """
        async with self.session.get(url) as resp:
            resp.raise_for_status()
            size = int(resp.headers.get("Content-Length", 0))
            with tqdm(total=size, unit='B', unit_scale=True, unit_divisor=1024,
                      desc=desc, miniters=1, leave=False, disable=None) as progress:
                with open(fname, "wb") as out:
                    while True:
                        block = await resp.content.read(1024*1024)
                        if not block:
                            break
                        out.write(block)
                        progress.update(len(block))

    async def get_ftp_listing(self, url):
        """Returns list of files at FTP **url**"""
        logger.debug("FTP: listing %s", url)
        if self.cache and url in self.cache["ftp_list"]:
            return self.cache["ftp_list"][url]

        parsed = urlparse(url)
        async with aioftp.ClientSession(parsed.netloc,
                                        password=self.USER_AGENT+"@") as client:
            res = [str(path) for path, _info in await client.list(parsed.path)]
        if self.cache:
            self.cache["ftp_list"][url] = res
        return res

    async def get_checksum_from_ftp(self, url, _desc=None):
        """Compute sha256 checksum of content at ftp **url**

        Does not show progress monitor at this time (would need to
        get file size first)
        """
        parsed = urlparse(url)
        checksum = sha256()
        async with aioftp.ClientSession(parsed.netloc,
                                        password=self.USER_AGENT+"@") as client:
            async with client.download_stream(parsed.path) as stream:
                async for block in stream.iter_by_block():
                    checksum.update(block)
        return checksum.hexdigest()
