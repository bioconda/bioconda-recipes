"""
Chat with the bot via Gitter
"""

import asyncio
import logging
from typing import Any, Dict, List

import aiohttp

from .. import gitter
from ..gitter import AioGitterAPI, GitterAPI
from .commands import command_routes

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

"""
https://webhooks.gitter.im/e/b9e5fad23b9cf034879083a

POST
{ message: 'message', level='error|normal' }
"""


class GitterListener:
    """Listens to messages in a Gitter chat room

    Args:
      app: Web Server Application
      api: Gitter API object
      rooms: Map containing rooms and their respective github user/repo
    """
    def __init__(self, app: aiohttp.web.Application, token: str, rooms: Dict[str, str],
                 session: aiohttp.ClientSession, ghappapi) -> None:
        self.rooms = rooms
        self._ghappapi = ghappapi
        self._api = AioGitterAPI(app['client_session'], token)
        self._user: gitter.User = None
        self._tasks: List[Any] = []
        self._session = session
        app.on_startup.append(self.start)
        app.on_shutdown.append(self.shutdown)

    def __str__(self) -> str:
        return f"{self.__class__.__name__}"

    async def start(self, app: aiohttp.web.Application) -> None:
        """Start listeners"""
        self._user = await self._api.get_user()

        logger.debug("%s: User Info: %s", self, self._user)
        for room in await self._api.list_rooms():
            logger.debug("%s: Room Info: %s", self, room)
        logger.debug("%s: Groups Info: %s", self, await self._api.list_groups())

        self._tasks = [app.loop.create_task(self.listen(room))
                       for room in self.rooms]

    async def shutdown(self, _app: aiohttp.web.Application) -> None:
        """Send cancel signal to listener"""
        logger.info("%s: Shutting down listeners", self)
        for task in self._tasks:
            task.cancel()
        for task in self._tasks:
            await task
        logger.info("%s: Shut down all listeners", self)

    async def listen(self, room_name: str) -> None:
        """Main run loop"""
        try:
            user, repo = self.rooms[room_name].split('/')
            logger.error("Listening in %s for repo %s/%s", room_name, user, repo)
            while True:
                try:
                    room = await self._api.get_room(room_name)
                    logger.info("%s: joining %s", self, room_name)
                    await self._api.join_room(self._user, room)
                    logger.info("%s: listening in %s", self, room_name)
                    async for message in self._api.iter_chat(room):
                        # getting a new ghapi object for every message because our
                        # creds time out. Ideally, the api class would take care of that.
                        ghapi = await self._ghappapi.get_github_api(False, user, repo)
                        await self.handle_msg(room, message, ghapi)
                except (aiohttp.ClientConnectionError,
                        asyncio.TimeoutError):
                    pass
                except aiohttp.ClientResponseError as exc:
                    logger.exception("HTTP Error Code %s while listening to room %s", exc.code, room_name)
                except TypeError as exc:
                    logger.exception("Type error caught. Resuming")
                await asyncio.sleep(1)
        except asyncio.CancelledError:
            logger.error("%s: stopped listening in %s", self, room_name)
            async with aiohttp.ClientSession() as session:
                self._api._session = session
                res = await self._api.leave_room(self._user, room)
                logger.error("%s: left room %s", self, room_name)
        except Exception:
            logger.exception("%s: exiting with uncaught exception", self)
            raise

    async def handle_msg(self, room: gitter.Room, message: gitter.Message, ghapi) -> None:
        """Parse Gitter message and dispatch via command_routes"""
        await self._api.mark_as_read(self._user, room, [message.id])
        if self._user.id not in (m.userId for m in message.mentions):
            if self._user.username.lower() in (m.screenName.lower() for m in message.mentions):
                await self._api.send_message(room, "@%s - are you talking to me?", message.fromUser.username)
            return
        command = message.text.strip().lstrip('@'+self._user.username).strip()
        if command == message.text.strip():
            await self._api.send_message(room, "Hmm? Someone talking about me?", message.fromUser.username)
            return
        cmd, *args = command.split()
        issue_number = None
        try:
            if args[-1][0] == '#':
                issue_number = int(args[-1][1:])
                args.pop()
        except (ValueError, IndexError):
            pass

        response = await command_routes.dispatch(cmd.lower(), ghapi, issue_number, message.fromUser.username, *args)
        if response:
            await self._api.send_message(room, "@%s: %s", message.fromUser.username, response)
        else:
            await self._api.send_message(room, "@%s: command failed", message.fromUser.username)
