"""Provides utilities for async processing"""

import abc
import asyncio
import logging

from concurrent.futures import ProcessPoolExecutor
from typing import List, Generic, Type, TypeVar

from .utils import tqdm


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

    @property
    def name(self):
        """Name of class"""
        return self.__class__.__name__


class AsyncFilter(abc.ABC, Generic[ITEM]):
    """Function object type called by Scanner"""
    def __init__(self, pipeline: "AsyncPipeline", *_args, **_kwargs) -> None:
        self.pipeline = pipeline

    @abc.abstractmethod
    async def apply(self, recipe: ITEM) -> ITEM:
        """Process a recipe. Returns False if processing should stop"""

    async def async_init(self) -> None:
        """Called inside loop before processing"""

    def finalize(self) -> None:
        """Called at the end of a run"""


class AsyncPipeline(Generic[ITEM]):
    """Processes items in an asyncio pipeline"""

    def __init__(self, max_inflight: int = 100) -> None:
        try:  # get or create loop (threads don't have one)
            #: our asyncio loop
            self.loop = asyncio.get_event_loop()
        except RuntimeError:
            self.loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self.loop)
        #: semaphore to limit io parallelism
        self.io_sem: asyncio.Semaphore = asyncio.Semaphore(1)
        #: must never run more than one conda at the same time
        self.conda_sem: asyncio.Semaphore = asyncio.Semaphore(1)
        #: the filters successively applied to each item
        self.filters: List[AsyncFilter] = []
        #: executor running things in separate python processes
        self.proc_pool_executor = ProcessPoolExecutor(3)
        #: semaphore limiting the number of items processed concurrently
        self.limit_inflight = asyncio.Semaphore(max_inflight)

    def add(self, filt: Type[AsyncFilter[ITEM]], *args, **kwargs) -> None:
        """Adds `Filter` to this `Scanner`"""
        self.filters.append(filt(self, *args, **kwargs))

    def run(self) -> bool:
        """Enters the asyncio loop and manages shutdown."""
        try:
            task = asyncio.ensure_future(self._async_run())
            self.loop.run_until_complete(task)
            logger.warning("Finished update")
        except (KeyboardInterrupt, EndProcessing) as exc:
            if isinstance(exc, KeyboardInterrupt):
                logger.error("Ctrl-C pressed - aborting...")
            if isinstance(exc, EndProcessing):
                logger.error("Terminating...")
            task.cancel()
            try:
                self.loop.run_until_complete(task)
            except asyncio.CancelledError:
                pass

        for filt in self.filters:
            filt.finalize()
        return task.result()

    def get_items(self) -> List[ITEM]:
        """Load items"""
        return []

    async def _async_run(self) -> bool:
        """Runner within async loop"""
        await asyncio.gather(*(filt.async_init() for filt in self.filters))
        coros = [
            asyncio.ensure_future(
                self.process(item)
            )
            for item in self.get_items()
        ]
        try:
            with tqdm(asyncio.as_completed(coros),
                      total=len(coros)) as tcoros:
                return all([await coro for coro in tcoros])
        except asyncio.CancelledError:
            for coro in coros:
                coro.cancel()
            await asyncio.wait(coros)
            return False

    async def process(self, item: ITEM) -> bool:
        """Applies the filters to an item"""
        async with self.limit_inflight:
            try:
                for filt in self.filters:
                    item = await filt.apply(item)
            except asyncio.CancelledError:
                return False
            except EndProcessingItem as item_error:
                item_error.log(logger)
                raise
            except Exception:  # pylint: disable=broad-except
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
