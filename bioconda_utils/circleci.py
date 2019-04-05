import abc
import logging
from typing import Any, Mapping, Optional, Tuple
import uritemplate
import urllib
import json

import aiohttp


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

class CircleAPI(abc.ABC):
    CIRCLE_API = "https://circleci.com/api/v1.1"

    LIST_ARTIFACTS = "/project/{vcs_type}/{username}/{project}/{build_num}/artifacts"
    TRIGGER_REBUILD = "/project/{vcs_type}/{username}/{project}/build"
    RECENT_BUILDS = "/project/{vcs_type}/{username}/{project}/tree/{path}"

    def __init__(self,
                 token: Optional[str] = None,
                 vcs_type: str = 'github',
                 username: str = 'bioconda',
                 project: str = 'bioconda-recipes') -> None:
        self.token = token
        self.vcs_type = vcs_type
        self.username = username
        self.project = project

    @property
    def var_data(self):
        return {
            'vcs_type': self.vcs_type,
            'username': self.username,
            'project': self.project,
        }

    @abc.abstractmethod
    async def _request(self, method: str, url: str,
                       headers: Mapping[str, str],
                       body: bytes = b'') -> Tuple[int, Mapping[str, str], bytes]:
        """Execute HTTP request (overriden by IO prividing subclass)"""

    async def _make_request(self, method: str, url: str, var_dict: Mapping[str, str],
                            data: Any = None,
                            accept: str = "application/json") -> Any:
        """Make HTTP request"""
        url = ''.join((self.CIRCLE_API, url, "{?circle-token}"))
        url = uritemplate.expand(url, var_dict=var_dict)
        headers = {}
        headers['accept'] = accept
        charset = 'utf-8'

        body = b''
        if isinstance(data, str):
            body = data.encode(charset)
        elif isinstance(data, Mapping):
            body = json.dumps(data).encode(charset)
            headers['content-type'] = "application/json; charset=" + charset
        headers['content-length'] = str(len(body))
        status, headers, response = await self._request(method, url, headers, body)
        if status == 404:
            logger.error("Got 404 for %s", url)
            return []
        response_text = response.decode(charset)
        try:
            return json.loads(response_text)
        except json.decoder.JSONDecodeError as exc:
            logger.error("Call to '%s' yielded text '%s' - not JSON",
                         url.replace(self.token, "******"),
                         response_text.replace(self.token, "******"))
        return response_text

    async def list_artifacts(self, build_number: int):
        var_data = self.var_data
        var_data['build_num'] = build_number
        res = await self._make_request('GET', self.LIST_ARTIFACTS, var_data)
        return [item['url'] for item in res]

    async def list_recent_builds(self, path: str):
        """path must be 'pull/123' for fors and branchname for local

        returns list of dict:
          build_num, has_artifacts, status, timedout, canceled, canceller,
          workflows/job_name, vcs_revision, build_time_millis
        """
        var_data = self.var_data
        var_data['path'] = path
        res = await self._make_request('GET', self.RECENT_BUILDS, var_data)
        return res

    async def trigger_rebuild(self, branch: str, sha: str):
        data = {
            'revision': sha,
            'branch': branch
        }
        return await self._make_request('POST', self.TRIGGER_REBUILD, self.var_data, data=data)


class AsyncCircleAPI(CircleAPI):
    def __init__(self, session: aiohttp.ClientSession, *args: Any, **kwargs: Any) -> None:
        self._session = session
        super().__init__(*args, **kwargs)

    async def _request(self, method: str, url: str,
                       headers: Mapping[str, str],
                       body: bytes = b'') -> Tuple[int, Mapping[str, str], bytes]:
        async with self._session.request(method, url, headers=headers, data=body) as response:
            return response.status, response.headers, await response.read()
