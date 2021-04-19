"""
`Gitter.im <https://gitter.im>`_ Web-API Bindings
"""

import abc
import logging
import json
import urllib

from collections import namedtuple
from typing import Any, Dict, List, Mapping, Optional, Tuple, NamedTuple, AsyncIterator

import aiohttp
import uritemplate


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class User(NamedTuple):
    """Gitter User"""
    @classmethod
    def from_dict(cls, data):
        """Create `User` from `dict`"""
        return cls(**data)

    #: User ID
    id: str
    #: Gitter username (OAUTH - Github/Gitlab)
    username: str
    #: Gitter displayname (real name)
    displayName: str
    #: Profile URL (relative)
    url: str
    #: Avatar URL
    avatarUrl: str
    #: Small avatar URL
    avatarUrlSmall: str
    #: Medium avatar URL
    avatarUrlMedium: str
    #: Version
    v: str
    #: Gravatar Version (used to force cache flushing)
    gv: str
    #: List of OAUTH providers for user
    providers: List[str] = None


class Mention(NamedTuple):
    """Gitter User Mention"""
    @classmethod
    def from_dict(cls, data):
        """Create `User` from `dict`"""
        return cls(**data)

    #: User Name
    screenName: str
    #: User ID
    userId: str = None
    #: User IDs
    userIds: List[str] = None


class Message(NamedTuple):
    """Gitter Chat Message"""
    @classmethod
    def from_dict(cls, data):
        """Create `Message` from `dict`"""
        if 'mentions' in data:
            data['mentions'] = [Mention.from_dict(user) for user in data['mentions']]
        if 'fromUser' in data:
            data['fromUser'] = User.from_dict(data['fromUser'])
        return cls(**data)

    #: Message ID
    id: str
    #: Message content (markdown)
    text: str
    #: Message content (HTML)
    html: str
    #: Posting timestamp (ISO)
    sent: str
    #: User by whom message was sent
    fromUser: User
    #: Flag indicating whether we have read this
    unread: bool
    #: Number of users who read message
    readBy: int
    #: URLs present in message
    urls: List[str]
    #: @mentions in message
    mentions: List[Mention]
    #: Github #ISSUE references in message
    issues: List[str]
    #: (Unused)
    meta: str
    #: Version
    v: str
    #: Gravatar Version (used to force cache flushing)
    gv: str = None
    #: Edit timestamp (ISO)
    editedAt: str = None



class Room(NamedTuple):
    """Gitter Chat Room"""
    @classmethod
    def from_dict(cls, data):
        """Create `Room` from `dict`"""
        if 'user' in data:
            data['user'] = User.from_dict(data['user'])
        return cls(**data)

    #: Room ID
    id: str
    #: Room Name (e.g. ``bioconda/Lobby``)
    name: str
    #: Room Topic
    topic: str
    #: List of users joined in room
    userCount: int
    #: Number of unread mentions of current user
    mentions: List[str]
    #: Flag marking this room as silenced (no notifications)
    lurk: bool
    #: URL to this room for browser
    url: str
    #: Type of room (``ORG``, ``REPO``, ``ONETOONE``,
    #: ``ORG_CHANNEL``, ``REPO_CHANNEL``, ``USER_CHANNEL``)
    githubType: str
    #: List of tags attached to room
    tags: List[str]
    #: Number of unread messages for current user
    unreadItems: int
    #: Gravatar URL
    avatarUrl: str
    #: unknown
    roomMember: str
    #: unknown
    groupId: str
    #: unknown
    public: str
    #: Last time (ISO) room was accessed
    lastAccessTime: str = None
    #: Flag marking this room as favorite
    favourite: bool = False
    #: Flag marking personal chats
    oneToOne: bool = None
    #: User if one-to-one
    user: User = None
    #: Room URI
    uri: str = None
    #: Unknown
    security: str = None
    #: unknown
    noindex: str = None
    #: Unknown
    group: str = None
    #: Version
    v: str = None


class GitterAPI:
    """Sans-IO Base Class for Gitter API

    .. rubric:: Methods

    .. autosummary::

       list_rooms
       get_room
       join_room
       leave_room
       edit_room
       list_unread_items
       mark_as_read
       get_message
       send_message
       edit_message
       list_groups
       get_user
       iter_chat

    .. rubric:: Details

    """

    #: Base URL for Gitter API calls
    _GITTER_API = "https://api.gitter.im/v1"
    #: Base URL for Streaming Gitter API calls
    _GITTER_STREAM_API = "https://stream.gitter.im/v1"

    #: Resource for chat messages (can stream)
    _MESSAGES = "/rooms/{roomId}/chatMessages{/messageId}"
    #: Resource for room listing / searching
    _ROOMS = "/rooms{/roomId}"
    #: Resource for rooms associated with user
    _USER_ROOMS = "/user/{userId}/rooms"
    #: Rsource for unread items
    _UNREAD = "/user/{userId}/rooms/{roomId}/unreadItems"
    #: Resource for rooms associated with user
    _ROOM_USERS = "/rooms/{roomId}/users{/userId}"
    #: Resource for group listing
    _LIST_GROUPS = "/groups"
    #: Resource for current user
    _GET_USER = "/user/me"

    def __init__(self, token: str) -> None:
        self.token = token
        self.debug_once = False

    @abc.abstractmethod
    async def _request(self, method: str, url: str, headers: Mapping[str, str],
                       body: bytes = b'') -> Tuple[int, Mapping[str, str], bytes]:
        """Execute HTTP request (implemented by IO providing subclass)

        Args:
          method: one of ``GET``, ``POST``, ``PATCH``, etc
          url: HTTP URL to make request at
          headers: Dictionary of headers to send
          body: Body data to send

        Returns:
          Tuple comprising return code, return header dictionary and return data
        """

    @abc.abstractmethod
    async def _stream_request(self, method: str, url: str,
                              headers: Mapping[str, str],
                              body: bytes = b'') -> AsyncIterator[bytes]:
        """Execute streaming HTTP request (implement by IO providing subclass)

        Args:
          method: one of ``GET``, ``POST``, ``PATCH``, etc
          url: HTTP URL to make request at
          headers: Dictionary of headers to send
          body: Body data to send

        Returns:
          Async iterator over data chunks
        """

    def _prepare_request(self, url: str, var_dict: Mapping[str, str],
                         data: Any = None,
                         charset: str = 'utf-8',
                         accept: str = "application/json") -> Tuple[str, Mapping[str, str], bytes]:
        """Prepare url, headers and json body for request"""
        url = uritemplate.expand(url, var_dict=var_dict)
        headers = {}
        headers['accept'] = accept
        headers['Authorization'] = "Bearer " + self.token

        body = b''
        if isinstance(data, str):
            body = data.encode(charset)
        elif isinstance(data, Mapping):
            body = json.dumps(data).encode(charset)
            headers['content-type'] = "application/json; charset=" + charset
        headers['content-length'] = str(len(body))
        return url, headers, body

    async def _make_request(self, method: str, url: str, var_dict: Mapping[str, str],
                            data: Any = None,
                            accept: str = "application/json") -> Tuple[str, Any]:
        """Make HTTP request"""
        charset = 'utf-8'
        url = ''.join((self._GITTER_API, url))
        url, headers, body = self._prepare_request(url, var_dict, data, charset, accept)
        status, res_headers, response = await self._request(method, url, headers, body)

        if self.debug_once:
            self.debug_once = False
            logger.error("Called %s / %s", method, url)
            logger.error("Headers: %s", headers)
            logger.error("Body: %s", body)
            logger.error("Result Status: %s", status)
            logger.error("Result Headers: %s", res_headers)
            logger.error("Response: %s", response.decode(charset))

        response_text = response.decode(charset)
        try:
            return response_text, json.loads(response_text)
        except json.decoder.JSONDecodeError:
            logger.error("Call to '%s' yielded text '%s' - not JSON",
                         url.replace(self.token, "******"),
                         response_text.replace(self.token, "******"))
        return response_text, None

    async def _make_stream_request(self, method: str, url: str, var_dict: Mapping[str, str],
                                   data: Any = None,
                                   accept: str = "application/json") -> AsyncIterator[Any]:
        """Make streaming HTTP request"""
        charset = 'utf-8'
        url = ''.join((self._GITTER_STREAM_API, url))
        url, headers, body = self._prepare_request(url, var_dict, data, charset, accept)
        async for line_bytes in self._stream_request(method, url, headers, body):
            line_str = line_bytes.decode(charset)
            if not line_str.strip():
                continue
            try:
                yield json.loads(line_str)
            except json.decoder.JSONDecodeError:
                logger.error("Failed to decode json in line %s", line_str)

    async def list_rooms(self, name: str = None) -> List[Room]:
        """Get list of current user's rooms

        The list is filtered to match provided arguments.

        Args:
          name: Room name
        """
        _, data = await self._make_request('GET', self._ROOMS, {})
        if not data:
            return []
        rooms = [Room.from_dict(item) for item in data]
        if name:
            rooms = list(filter(lambda room: room.name == name, rooms))
        return rooms

    async def get_room(self, uri: str) -> Room:
        """Get a room using its URI"""
        _, data = await self._make_request('POST', self._ROOMS, {}, {'uri': uri})
        return Room.from_dict(data)

    async def join_room(self, user: User, room: Room) -> None:
        """Add **user** to a **room**"""
        await self._make_request('POST', self._USER_ROOMS, {'userId': user.id},
                                 {'id': room.id})

    async def leave_room(self, user: User, room: Room) -> bool:
        """Remove **user** from **room**"""
        try:
            await self._make_request('DELETE', self._ROOM_USERS,
                                     {'roomId': room.id, 'userId': user.id})
        except aiohttp.ClientResponseError as exc:
            if exc.code in (404,):
                return False
        return True

    async def edit_room(self, room: Room, topic: str = None, tags: str = None,
                        noindex: bool = None) -> None:
        """Set **topic**, **tags** or **noindex** for **room**"""
        data = {}
        if topic:
            data['topic'] = topic
        if tags:
            data['tags'] = tags
        if noindex:
            data['noindex'] = str(noindex)
        await self._make_request('PUT', self._ROOMS, {'roomId': room.id}, data)

    async def list_unread_items(self, user: User, room: Room) -> Tuple[List[str], List[str]]:
        """Get Ids for unread items of **user** in **room**

        Returns:
          Two lists of chat IDs are returned. The first are all unread mentions, the second only
          those in which the user was @Mentioned.
        """
        _, data = await self._make_request('GET', self._UNREAD,
                                           {'userId': user.id, 'roomId': room.id})
        return data.get('chat', []), data.get('mention', [])

    async def mark_as_read(self, user: User, room: Room, ids: List[str]) -> None:
        """Mark chat messages listed in **ids** as read"""
        await self._make_request('POST', self._UNREAD,
                                 {'userId': user.id, 'roomId': room.id},
                                 {'chat': ids})

    async def get_message(self, room: Room, msgid: str) -> Message:
        """Get a single message by its **id**"""
        _, data = await self._make_request('GET', self._MESSAGES,
                                           {'roomId': room.id, 'messageId': msgid})
        return Message.from_dict(data)

    async def send_message(self, room: Room, text: str, *args: Any) -> Message:
        """Send a new message"""
        _, data = await self._make_request('POST', self._MESSAGES,
                                           {'roomId': room.id},
                                           {'text': text % args})
        return Message.from_dict(data)

    async def edit_message(self, room: Room, message: Message, text: str) -> Message:
        """Edit a message"""
        _, data = await self._make_request('PUT', self._MESSAGES,
                                           {'roomId': room.id, 'messageId': message.id},
                                           {'text': text})
        return Message.from_dict(data)

    async def list_groups(self):
        """Get list of current user's groups"""
        _, data = await self._make_request('GET', self._LIST_GROUPS, {})
        return data

    async def get_user(self) -> User:
        """Get current user"""
        _, data = await self._make_request('GET', self._GET_USER, {})
        return User.from_dict(data)

    async def iter_chat(self, room: Room) -> AsyncIterator[Message]:
        """Listen to chat messages

        Args:
          room: Room to listen in. Use `list_rooms` to find `Room`.

        Returns:
          async iterator over chat messages
        """
        stream = self._make_stream_request('GET', self._MESSAGES, {'roomId': room.id})
        async for data in stream:
            yield Message.from_dict(data)


class AioGitterAPI(GitterAPI):
    """AioHTTP based implementation of GitterAPI"""
    def __init__(self, session: aiohttp.ClientSession, *args: Any, **kwargs: Any) -> None:
        self._session = session
        super().__init__(*args, **kwargs)

    async def _request(self, method: str, url: str,
                       headers: Mapping[str, str],
                       body: bytes = b'') -> Tuple[int, Mapping[str, str], bytes]:
        async with self._session.request(method, url, headers=headers, data=body) as response:
            response.raise_for_status()
            return response.status, response.headers, await response.read()

    async def _stream_request(self, method: str, url: str,
                              headers: Mapping[str, str],
                              body: bytes = b'') -> AsyncIterator[bytes]:
        timeout = aiohttp.ClientTimeout(total=3600, sock_read=3600)
        async with self._session.request(method, url, headers=headers, data=body,
                                         timeout=timeout) as response:
            response.raise_for_status()
            async for line_bytes in response.content:
                yield line_bytes
