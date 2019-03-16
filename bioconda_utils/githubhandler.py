"""Highlevel API for managing PRs on Github"""

import abc
import datetime
import logging
import time

from copy import copy
from enum import Enum
from typing import Any, Dict, List, Optional, Tuple

import aiohttp
import backoff
import cachetools
import gidgethub
import gidgethub.aiohttp
import gidgethub.sansio
import jwt


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


#: State for Github Issues
IssueState = Enum("IssueState", "open closed all")  # pylint: disable=invalid-name

#: State of Github Check Run
CheckRunStatus = Enum("CheckRunState", "queued in_progress completed")

#: Conclusion of Github Check Run
CheckRunConclusion = Enum("CheckRunConclusion",
                          "success failure neutral cancelled timed_out action_required")


def iso_now() -> str:
    """Creates ISO 8601 timestamp in format
    ``YYYY-MM-DDTHH:MM:SSZ`` as required by Github
    """
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat()+'Z'


class GitHubHandler:
    """Handles interaction with GitHub

    Arguments:
      token: OAUTH token granting permissions to GH
      dry_run: Don't actually modify things if set
      to_user: Target User/Org for PRs
      to_repo: Target repository within **to_user**
    """
    PULLS = "/repos/{user}/{repo}/pulls{/number}{?head,base,state}"
    PULL_FILES = "/repos/{user}/{repo}/pulls/{number}/files"
    PULL_COMMITS = "/repos/{user}/{repo}/pulls/{number}/commits"
    ISSUES = "/repos/{user}/{repo}/issues{/number}"
    COMMENTS = "/repos/{user}/{repo}/issues/{number}/comments"
    ORG_MEMBERS = "/orgs/{user}/members{/username}"
    CHECK_RUN = "/repos/{user}/{repo}/check-runs{/id}"

    STATE = IssueState

    def __init__(self, token: str = None,
                 dry_run: bool = False,
                 to_user: str = "bioconda",
                 to_repo: str = "bioconda-recipes",
                 installation: int = None) -> None:
        self.token = token
        self.dry_run = dry_run
        self.installation = installation
        self.user = to_user
        self.repo = to_repo
        self.var_default = {'user': to_user,
                            'repo': to_repo}

        # filled in by login():
        self.api: gidgethub.abc.GitHubAPI = None
        self.username: str = None

    def __str__(self):
        return f"{self.__class__.__name__}({self.user}/{self.repo})"

    def __repr__(self):
        return str(self)

    def for_json(self):
        return {
            '__module__': self.__module__,
            '__type__': self.__class__.__qualname__,
            'dry_run': self.dry_run,
            'to_user': self.user,
            'to_repo': self.repo,
            'installation': self.installation
        }

    def __to_json__(self):
        return self.for_json()

    @property
    def rate_limit(self) -> gidgethub.sansio.RateLimit:
        """Last recorded rate limit data"""
        return self.api.rate_limit

    def set_oauth_token(self, token: str) -> None:
        """Update oauth token for the wrapped GitHubAPI object"""
        self.api.oauth_token = token

    @abc.abstractmethod
    def create_api_object(self, *args, **kwargs):
        """Create API object"""

    def get_file_relurl(self, path: str, branch_name: str = "master") -> str:
        """Format domain relative url for **path** on **branch_name**"""
        return "/{user}/{repo}/tree/{branch_name}/{path}".format(
            branch_name=branch_name, path=path, **self.var_default)

    async def login(self, *args, **kwargs):
        """Log into API (fills `self.username`)"""

        self.create_api_object(*args, **kwargs)

        if not self.token:
            self.username = "UNKNOWN [no token]"
        else:
            user = await self.api.getitem("/user")
            self.username = user["login"]

    async def is_member(self, username) -> bool:
        """Check if **username** is member of current org"""
        if not username:
            return False
        var_data = copy(self.var_default)
        var_data['username'] = username
        try:
            await self.api.getitem(self.ORG_MEMBERS, var_data)
        except gidgethub.BadRequest:
            logger.debug("User %s is not a member of %s", username, var_data['user'])
            return False
        logger.debug("User %s IS a member of %s", username, var_data['user'])
        return True

    # pylint: disable=too-many-arguments
    @backoff.on_exception(backoff.fibo, gidgethub.BadRequest, max_tries=14)
    async def get_prs(self,
                      from_branch: Optional[str] = None,
                      from_user: Optional[str] = None,
                      to_branch: Optional[str] = None,
                      number: Optional[int] = None,
                      state: Optional[IssueState] = None) -> List[Dict[Any, Any]]:
        """Retrieve list of PRs matching parameters

        Arguments:
          from_branch: Name of branch from which PR asks to pull
          from_user: Name of user/org in from which to pull
                     (default: from auth)
          to_branch: Name of branch into which to pull (default: master)
          number: PR number
        """
        var_data = copy(self.var_default)
        if not from_user:
            from_user = self.username
        if from_branch:
            if from_user:
                var_data['head'] = f"{from_user}:{from_branch}"
            else:
                var_data['head'] = from_branch
        if to_branch:
            var_data['base'] = to_branch
        if number:
            var_data['number'] = str(number)
        if state:
            var_data['state'] = state.name.lower()

        return await self.api.getitem(self.PULLS, var_data)

    async def iter_pr_commits(self, number: int):
        """Create iterator over commits in a PR"""
        var_data = copy(self.var_default)
        var_data['number'] = str(number)
        return self.api.getiter(self.PULL_COMMITS, var_data)

    # pylint: disable=too-many-arguments
    async def create_pr(self, title: str,
                        from_branch: Optional[str] = None,
                        from_user: Optional[str] = None,
                        to_branch: Optional[str] = "master",
                        body: Optional[str] = None,
                        maintainer_can_modify: bool = True) -> Dict[Any, Any]:
        """Create new PR

        Arguments:
          title: Title of new PR
          from_branch: Name of branch from which PR asks to pull
          from_user: Name of user/org in from which to pull
          to_branch: Name of branch into which to pull (default: master)
          body: Body text of PR
          maintainer_can_modify: Whether to allow maintainer to modify from_branch
        """
        var_data = copy(self.var_default)
        if not from_user:
            from_user = self.username
        data: Dict[str, Any] = {'title': title,
                                'body': '',
                                'maintainer_can_modify': maintainer_can_modify}
        if body:
            data['body'] += body
        if from_branch:
            if from_user and from_user != self.username:
                data['head'] = f"{from_user}:{from_branch}"
            else:
                data['head'] = from_branch
        if to_branch:
            data['base'] = to_branch

        logger.debug("PR data %s", data)
        if self.dry_run:
            logger.info("Would create PR '%s'", title)
            return {'number': -1}
        logger.info("Creating PR '%s'", title)
        return await self.api.post(self.PULLS, var_data, data=data)

    async def modify_issue(self, number: int,
                           labels: Optional[List[str]] = None,
                           title: Optional[str] = None,
                           body: Optional[str] = None) -> Dict[Any, Any]:
        """Modify existing issue (PRs are issues)

        Arguments:
          labels: list of labels to assign to issue
          title: new title
          body: new body
        """
        var_data = copy(self.var_default)
        var_data["number"] = str(number)
        data: Dict[str, Any] = {}
        if labels:
            data['labels'] = labels
        if title:
            data['title'] = title
        if body:
            data['body'] = body

        if self.dry_run:
            logger.info("Would modify PR %s", number)
            if title:
                logger.info("New title: %s", title)
            if labels:
                logger.info("New labels: %s", labels)
            if body:
                logger.info("New Body:\n%s\n", body)

            return {'number': number}
        logger.info("Modifying PR %s", number)
        return await self.api.patch(self.ISSUES, var_data, data=data)

    async def create_comment(self, number: int, body: str) -> int:
        """Create issue comment

        Arguments:
          number: Issue number
          body: Comment content
        """
        var_data = copy(self.var_default)
        var_data["number"] = str(number)
        data = {
            'body': body
        }
        if self.dry_run:
            logger.info("Would create comment on issue #%i", number)
            return -1
        logger.info("Creating comment on issue #%i", number)
        res = await self.api.post(self.COMMENTS, var_data, data=data)
        return res['id']

    async def get_pr_modified_files(self, number: int) -> List[Dict[str, Any]]:
        var_data = copy(self.var_default)
        var_data["number"] = str(number)
        return await self.api.getitem(self.PULL_FILES, var_data)

    async def create_check_run(self, name: str, head_sha: str):
        var_data = copy(self.var_default)
        data = {
            'name': name,
            'head_sha': head_sha,
        }
        accept = "application/vnd.github.antiope-preview+json"
        result = await self.api.post(self.CHECK_RUN, var_data, data=data, accept=accept)
        return int(result.get('id'))

    async def modify_check_run(self, number: int,
                               status: CheckRunStatus = None,
                               conclusion: CheckRunConclusion = None,
                               output_title: str = None,
                               output_summary: str = None,
                               output_text: str = None,
                               output_annotations: List[Dict] = None):
        logger.info("Modifying check run %i: status=%s conclusion=%s title=%s",
                    number, status.name, conclusion.name if conclusion else "N/A", output_title)
        var_data = copy(self.var_default)
        var_data['id'] = str(number)
        data = {}
        if status is not None:
            data['status'] = status.name.lower()
            if status == CheckRunStatus.in_progress:
                data['started_at'] = iso_now()
        if conclusion is not None:
            data['conclusion'] = conclusion.name.lower()
            data['completed_at'] = iso_now()
        if output_title:
            data['output'] = {
                'title': output_title,
                'summary': output_summary or "",
                'text': output_text or "",
            }
            if output_annotations:
                data['output']['annotations']=output_annotations
        accept = "application/vnd.github.antiope-preview+json"
        return await self.api.patch(self.CHECK_RUN, var_data, data=data, accept=accept)


class AiohttpGitHubHandler(GitHubHandler):
    """GitHubHandler using Aiohttp for HTTP requests

    Arguments:
      session: Aiohttp Client Session object
      requester: Identify self (e.g. user agent)
    """
    def create_api_object(self, session: aiohttp.ClientSession,
                          requester: str, *args, **kwargs) -> None:
        self.api = gidgethub.aiohttp.GitHubAPI(
            session, requester, oauth_token=self.token
        )


class Event(gidgethub.sansio.Event):
    """Adds **get(path)** method to Github Webhook event"""
    def get(self, path: str, altvalue=KeyError) -> str:
        """Get subkeys from even data using slash separated path"""
        data = self.data
        try:
            for item in path.split("/"):
                data = data[item]
        except (KeyError, TypeError):
            if altvalue == KeyError:
                raise KeyError(f"No '{path}' in event type {self.event}") from None
            else:
                return altvalue
        return data


class GitHubAppHandler:
    """Handles interaction with Github as App"""

    #: Github API url for creating an access token for a specific installation
    #: of an app.
    INSTALLATION_TOKEN = "/app/installations/{installation_id}/access_tokens"

    #: Lifetime of JWT in seconds
    JWT_RENEW_PERIOD = 600

    def __init__(self, session: aiohttp.ClientSession,
                 app_name: str, app_key: str, app_id: str) -> None:
        #: Name of app
        self.name = app_name

        #: Our client session
        self._session = session
        #: Cache for GET queries
        self._cache = cachetools.LRUCache(maxsize=500)
        #: Authorization key
        self._app_key = app_key
        #: ID of app
        self._app_id = app_id
        #: JWT and its expiry
        self._jwt: Tuple[int, str] = (0, "")
        #: OAUTH tokens for installations
        self._tokens: Dict[str, Tuple[int, str]] = {}
        #: GitHubHandlers for each installation
        self._handlers: Dict[Tuple[str, str], GitHubHandler] = {}

        # Failing early is best - check that we can generate a JWT
        self.get_app_jwt()

    def get_app_jwt(self) -> str:
        """Returns JWT authenticating as this app"""
        now = int(time.time())
        expires, token = self._jwt
        if not expires or expires < now + 60:
            expires = now + self.JWT_RENEW_PERIOD
            payload = {
                'iat': now,
                'exp': expires,
                'iss': self._app_id,
            }
            token_utf8 = jwt.encode(payload, self._app_key, algorithm="RS256")
            token = token_utf8.decode("utf-8")
            self._jwt = (expires, token)
            msg = "Created new"
        else:
            msg = "Reusing"

        logger.debug("%s JWT valid for %i minutes", msg, (expires - now)/60)
        return token

    @staticmethod
    def parse_isotime(timestr: str) -> int:
        """Converts UTC ISO 8601 time stamp to seconds in epoch"""
        if timestr[-1] != 'Z':
            raise ValueError(f"Time String '%s' not in UTC")
        return int(time.mktime(time.strptime(timestr[:-1], "%Y-%m-%dT%H:%M:%S")))

    async def get_installation_token(self, installation: str, name: str = None) -> str:
        """Returns OAUTH token for installation referenced in **event**"""
        if name is None:
            name = installation
        now = int(time.time())
        expires, token = self._tokens.get(installation, (0, ''))
        if not expires or expires < now + 60:
            api = gidgethub.aiohttp.GitHubAPI(self._session, self.name)
            try:
                res = await api.post(
                    self.INSTALLATION_TOKEN,
                    {'installation_id': installation},
                    data=b"",
                    accept="application/vnd.github.machine-man-preview+json",
                    jwt=self.get_app_jwt()
                )
            except gidgethub.BadRequest:
                logger.exception("Failed to get installation token for %s", name)
                raise

            expires = self.parse_isotime(res['expires_at'])
            token = res['token']
            self._tokens[installation] = (expires, token)
            msg = "Created new"
        else:
            msg = "Reusing"

        logger.debug("%s token for %i valid for %i minutes",
                     msg, installation, (expires - now)/60)
        return token

    async def get_github_api(self, dry_run, to_user, to_repo, installation) -> GitHubHandler:
        """Returns the GitHubHandler for the installation the event came from"""

        handler_key = (installation, to_repo)
        api = self._handlers.get(handler_key)
        if api:
            # update oauth token (ours expire)
            api.set_oauth_token(await self.get_installation_token(installation))
        else:
            api = AiohttpGitHubHandler(
                await self.get_installation_token(installation),
                to_user=to_user, to_repo=to_repo, dry_run=dry_run,
                installation=installation
            )
            api.create_api_object(self._session, self.name)
            self._handlers[handler_key] = api
        return api
