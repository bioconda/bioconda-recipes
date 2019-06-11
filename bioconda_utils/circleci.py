"""
CircleCI Web-API Bindings
"""

import abc
import logging
from typing import Any, Mapping, Optional, Tuple, List
import uritemplate
import urllib
import json
import re

import aiohttp


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name

class CircleAPI(abc.ABC):
    """CircleCI API
    """
    CIRCLE_API = "https://circleci.com/api/v1.1"

    LIST_ARTIFACTS = "/project/{vcs_type}/{username}/{project}/{build_num}/artifacts"
    TRIGGER_REBUILD = "/project/{vcs_type}/{username}/{project}/build"
    BUILDS = "/project/{vcs_type}/{username}/{project}/tree/{path}"

    def __init__(self,
                 token: Optional[str] = None,
                 vcs_type: str = 'github',
                 username: str = 'bioconda',
                 project: str = 'bioconda-recipes') -> None:
        self.token = token
        self.vcs_type = vcs_type
        self.username = username
        self.project = project
        self.debug_once = False

    @property
    def var_data(self):
        """Defaults for this API instance"""
        return {
            'vcs_type': self.vcs_type,
            'username': self.username,
            'project': self.project,
            'circle-token': self.token,
        }

    @abc.abstractmethod
    async def _request(self, method: str, url: str,
                       headers: Mapping[str, str],
                       body: bytes = b'') -> Tuple[int, Mapping[str, str], bytes]:
        """Execute HTTP request (overriden by IO providing subclass)"""

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
        status, res_headers, response = await self._request(method, url, headers, body)

        if self.debug_once:
            self.debug_once = False
            logger.error("Called %s / %s", method, url)
            logger.error("Headers: %s", headers)
            logger.error("Body: %s", body)
            logger.error("Result Status: %s", status)
            logger.error("Result Headers: %s", res_headers)
            logger.error("Response: %s", response.decode(charset))

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

    async def list_artifacts(self, build_number: int) -> List[Mapping[str, Any]]:
        """Lists artifacts for build number

        Returns:
          List of artifacts described by ``path`` and ``url``
        """
        var_data = self.var_data
        var_data['build_num'] = build_number
        return await self._make_request('GET', self.LIST_ARTIFACTS, var_data)

    async def list_recent_builds(self, path: str, sha: str = None,
                                 skip_rebuilt: bool = True) -> List[Mapping[str, Any]]:
        """List recent builds for **path** (branch or pr)

        Note: skip rebuild seems to only apply to jobs, not workflow reruns.

        Arguments:
          path: Must be ``pull/123`` if on a fork, otherwise name of branch
          sha: name of optional sha to filter by
          skip_rebuilt: Skip artifacts from builds that have been rebuilt
        Returns:
          List of builds, each having ``build_num``, ``has_artifacts``, ``status``,
          ``timeout``, ``canceled``, ``canceller``, ``workflows/job_name``,
          ``vc_revision`, ``build_time_millis``
        """
        var_data = self.var_data
        var_data['path'] = path
        res = await self._make_request('GET', self.BUILDS, var_data)
        if sha is not None:
            res = [build for build in res if build["vcs_revision"] == sha]
        if skip_rebuilt:
            # try using 'retry_of` to remove builds
            rebuilt = set(build['retry_of'] for build in res if 'retry_of' in build)
            res = [build for build in res if build["build_num"] not in rebuilt]

            # now just pick the newest of each workflow_name/job_name
            new_res = []
            job_types = set()
            for build in sorted(res, key=lambda build: build['build_num'], reverse=True):
                job_type = (build['workflows']['workflow_name'],
                            build['workflows']['job_name'])
                if job_type in job_types:
                    continue
                job_types.add(job_type)
                new_res.append(build)
            res = new_res
        return res

    async def trigger_rebuild(self, branch: str, sha: str):
        """Trigger rebuilding **sha** on **branch**.

        Arguments:
          branch: Must be ``pull/123`` if on fork, otherwise name of branch
          sha: The SHA to rebuild
        """
        data = {
            'revision': sha,
            'branch': branch
        }
        return await self._make_request('POST', self.TRIGGER_REBUILD, self.var_data, data=data)

    async def trigger_job(self, branch="master", project=None, job=None, params=None):
        """Trigger specific job

        Arguments:
          branch: Must be ``pull/123`` if on fork, otherwise name of branch
          project: Optionally the project (repo) name
          job: Specific job from circle/config.yml to run
          params: Optional dict of parameters (envvars) to override
        """
        var_data = self.var_data
        var_data['path'] = branch
        if project:
            var_data['project'] = project

        data = {
            'build_parameters': params or {}
        }

        if job:
            data['build_parameters']['CIRCLE_JOB'] = job

        res = await self._make_request('POST', self.BUILDS, var_data, data=data)
        return res.get('build_url')

    async def get_artifacts(self, path: str, head_sha: str) -> List[Tuple[str, str, int]]:
        """Get artifacts for specific branch and head_sha

        For each artifact built for this sha, get the latest URL. Multiple builds
        may exist e.g. if a rebuild was triggered.

        Arguments:
          path: Must be ``pull/123`` if on fork, otherwise name of branch
          sha: The SHA to fetch artifacts for
        Returns:
          Mapping of relative path to full URL
        """
        build_numbers = [build["build_num"]
                         for build in await self.list_recent_builds(path, head_sha)]
        artifacts = []
        for buildno in sorted(build_numbers):
            artifacts.extend(
                (artifact['path'], artifact['url'], buildno)
                for artifact in await self.list_artifacts(buildno)
            )
        return artifacts


class SlackMessage:
    """Parses a Slack message as sent by CircleCI"""
    def __init__(self, _headers: Mapping[str, str], data: bytes):
        response_text = data.decode('utf-8')
        try:
            data = json.loads(response_text)
        except json.decoder.JSONDecodeError:
            raise RuntimeError("Unable to decore CircleCI Slack message")
        self.parsed = []
        err = False
        for attachment in data['attachments']:
            text = attachment['text']
            if text.startswith('Success:'):
                success = True
            elif text.startswith('Failed:'):
                success = False
            else:
                err = True
                continue
            urls = {key: url for url, key in re.findall(r'<(http[^|>]+)\|([^>]+)>', text)}
            self.parsed.append({
                'urls': urls,
                'success': success,
            })

    def __str__(self):
        return '|'.join(f"success={x['success']} {':'.join(x['urls'].keys())}"
                        for x in self.parsed)


class AsyncCircleAPI(CircleAPI):
    """CircleCI API using `aiohttp`"""
    def __init__(self, session: aiohttp.ClientSession, *args: Any, **kwargs: Any) -> None:
        self._session = session
        super().__init__(*args, **kwargs)

    async def _request(self, method: str, url: str,
                       headers: Mapping[str, str],
                       body: bytes = b'') -> Tuple[int, Mapping[str, str], bytes]:
        async with self._session.request(method, url, headers=headers, data=body) as response:
            return response.status, response.headers, await response.read()
