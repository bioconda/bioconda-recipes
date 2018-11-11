"""Highlevel API for managing PRs on Github"""

import abc
import logging

from copy import copy

from gidgethub.abc import GitHubAPI
from gidgethub import aiohttp as gh_aiohttp
import aiohttp

from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class GitHubHandler:
    """Handles interaction with GitHub

    Arguments:
      token: OAUTH token granting permissions to GH
      dry_run: Don't actually modify things if set
      to_user: Target User/Org for PRs
      to_repo: Target repository within **to_user**
    """
    USER_AGENT = "bioconda/bioconda-utils"
    PULLS = "/repos/{user}/{repo}/pulls{/number}{?head,base}"
    ISSUES = "/repos/{user}/{repo}/issues{/number}"

    def __init__(self, token: str,
                 dry_run: bool = False,
                 to_user: str = "bioconda",
                 to_repo: str = "bioconnda-recipes") -> None:
        self.token = token
        self.dry_run = dry_run
        self.var_default = {'user': to_user,
                            'repo': to_repo}

        # filled in by login():
        self.api: GitHubAPI = None
        self.username: str = None

    @abc.abstractmethod
    def create_api_object(self, *args, **kwargs):
        """Create API object"""

    async def login(self, *args, **kwargs):
        """Log into API (fills `self.username`)"""

        self.create_api_object(*args, **kwargs)

        user = await self.api.getitem("/user")
        self.username = user["login"]

    async def is_member(self, username):
        """Tests if **username** is a member"""
        # FIXME unfinished
        res = await self.gh.getitem("/orgs/:org/members/:username")

    async def get_prs(self,
                      from_branch: Optional[str] = None,
                      from_user: Optional[str] = None,
                      to_branch: Optional[str] = None,
                      number: Optional[int] = None) -> List[Dict[Any, Any]]:
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

        return await self.api.getitem(self.PULLS, var_data)

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
            if from_user:
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
            return {'number': number}
        logger.info("Modifying PR %s", number)
        return await self.api.patch(self.ISSUES, var_data, data=data)


class AiohttpGitHubHandler(GitHubHandler):
    """GitHubHandler using Aiohttp for HTTP requests

    Arguments:
      session: Aiohttp Client Session object
    """
    def create_api_object(self, session: aiohttp.ClientSession, *args, **kwargs):
        self.api = gh_aiohttp.GitHubAPI(session,
                                        self.USER_AGENT,
                                        oauth_token=self.token)
