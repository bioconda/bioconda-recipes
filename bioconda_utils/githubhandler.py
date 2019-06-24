"""Wrappers for Github Web-API Bindings"""

import abc
import base64
import datetime
import logging
import os
import time

from copy import copy
from enum import Enum
from typing import Any, AsyncIterator, Dict, List, Optional, Tuple, Union

import aiohttp
import backoff
import cachetools
import gidgethub
import gidgethub.aiohttp
import gidgethub.sansio
import jwt
import uritemplate


logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


#: State for Github Issues
IssueState = Enum("IssueState", "open closed all")  # pylint: disable=invalid-name

#: State of Github Check Run
CheckRunStatus = Enum("CheckRunState", "queued in_progress completed")

#: Conclusion of Github Check Run
CheckRunConclusion = Enum("CheckRunConclusion",
                          "success failure neutral cancelled timed_out action_required")

#: Merge method
MergeMethod = Enum("MergeMethod", "merge squash rebase")

#: Pull request review state
ReviewState = Enum("ReviewState", "APPROVED CHANGES_REQUESTED COMMENTED DISMISSED PENDING")

#: ContentType for Project Cards
CardContentType = Enum("CardContentType", "Issue PullRequest")

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
    USER              = "/user"
    USER_APPS         = "/user/installations"

    PULLS             = "/repos/{user}/{repo}/pulls{/number}{?head,base,state}"
    PULL_FILES        = "/repos/{user}/{repo}/pulls/{number}/files"
    PULL_COMMITS      = "/repos/{user}/{repo}/pulls/{number}/commits"
    PULL_MERGE        = "/repos/{user}/{repo}/pulls/{number}/merge"
    PULL_REVIEWS      = "/repos/{user}/{repo}/pulls/{number}/reviews{/review_id}"
    PULL_UPDATE       = "/repos/{user}/{repo}/pulls/{number}/update-branch"
    BRANCH_PROTECTION = "/repos/{user}/{repo}/branches/{branch}/protection"
    ISSUES            = "/repos/{user}/{repo}/issues{/number}"
    ISSUE_COMMENTS    = "/repos/{user}/{repo}/issues/{number}/comments"
    COMMENTS          = "/repos/{user}/{repo}/issues/comments{/comment_id}"
    CHECK_RUN         = "/repos/{user}/{repo}/check-runs{/id}"
    GET_CHECK_RUNS    = "/repos/{user}/{repo}/commits/{commit}/check-runs"
    GET_STATUSES      = "/repos/{user}/{repo}/commits/{commit}/statuses"
    CONTENTS          = "/repos/{user}/{repo}/contents/{path}{?ref}"
    GIT_REFERENCE     = "/repos/{user}/{repo}/git/refs/{ref}"
    ORG_MEMBERS       = "/orgs/{user}/members{/username}"
    ORG               = "/orgs/{user}"
    ORG_TEAMS         = "/orgs/{user}/teams{/team_slug}"

    PROJECTS_BY_REPO  = "/repos/{user}/{repo}/projects"
    PROJECT_COL_CARDS = "/projects/columns/{column_id}/cards"
    PROJECT_CARDS     = "/projects/columns/cards/{card_id}"

    TEAMS_MEMBERSHIP  = "/teams/{team_id}/memberships/{username}"

    SEARCH_ISSUES     = "/search/issues?q="

    STATE = IssueState

    def __init__(self, token: str = None,
                 dry_run: bool = False,
                 to_user: str = "bioconda",
                 to_repo: str = "bioconda-recipes",
                 installation: int = None) -> None:
        #: API Bearer Token
        self.token = token
        #: If set, no actual modifying actions are taken
        self.dry_run = dry_run
        #: The installation ID if this instance is connected to an App
        self.installation = installation
        #: Owner of the Repo
        self.user = to_user
        #: Name of the Repo
        self.repo = to_repo
        #: Default variables for API calls
        self.var_default = {'user': to_user,
                            'repo': to_repo}

        # filled in by login():
        #: Gidgethub API object
        self.api: gidgethub.abc.GitHubAPI = None
        #: Login username
        self.username: str = None
        #: User avatar URL
        self.avatar_url: str = None

    def __str__(self):
        return f"{self.user}/{self.repo}"

    def __repr__(self):
        return f"{self.__class__.__name__}({self.user}/{self.repo})"

    def for_json(self):
        """Return JSON repesentation of object"""
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
        self.token = token
        self.api.oauth_token = token

    @abc.abstractmethod
    def create_api_object(self, *args, **kwargs):
        """Create API object"""

    def get_file_relurl(self, path: str, branch_name: str = "master") -> str:
        """Format domain relative url for **path** on **branch_name**"""
        return "/{user}/{repo}/tree/{branch_name}/{path}".format(
            branch_name=branch_name, path=path, **self.var_default)

    async def login(self, *args, **kwargs) -> bool:
        """Log into API (fills `username`)"""

        self.create_api_object(*args, **kwargs)

        self.username = "UNKNOWN [no token]"
        self.avatar_url = None

        if self.token:
            user = await self.get_user()
            if user:
                self.username = user["login"]
                self.avatar_url = user["avatar_url"]
                return True

        return False

    async def get_user(self):
        try:
            return await self.api.getitem(self.USER)
        except gidgethub.GitHubException as exc:
            return {}

    async def iter_teams(self) -> AsyncIterator[Dict[str, Any]]:
        """List organization teams

        Returns:
          Async iterator over dicts, containing **id**,
          **name**, **slug**, **description**, etc.
        """
        async for team in self.api.getiter(self.ORG_TEAMS, self.var_default):
            yield team

    async def get_team_id(self, team_slug: str = None,
                          team_name: str = None) -> Optional[int]:
        """Get the Team ID from the Team slug

        If both are set, **team_slug** is tried first.

        Args:
          team_slug: urlized team name, e.g. "justice-league" for "Justice League"
          team_name: alternative, use normal name (requires extra API call internally)

        Returns:
          Team ID if found, otherwise `None`
        """
        if team_slug:
            var_data = copy(self.var_default)
            var_data['team_slug'] = team_slug
            try:
                team = await self.api.getitem(self.ORG_TEAMS, var_data)
                if team and 'id' in team:
                    return team['id']
            except gidgethub.BadRequest as exc:
                if exc.status_code != 404:
                    raise

        if team_name:
            async for team in self.iter_teams():
                if team.get('name') == team_name:
                    return team.get('id')

    async def is_team_member(self, username: str, team: Union[str, int]) -> bool:
        """Check if user is a member of given team

        Args:
          username: Name of user to check
          team: ID, Slug or Name of team to check
        Returns:
          True if the user is a member of the team
        """
        if isinstance(team, int):
            team_id = team
        else:
            team_id = await self.get_team_id(team, team)
            if not team:
                logger.error("Could not find team for name '%s'", team)
                return False

        var_data = {
            'username': username,
            'team_id': team_id,
        }
        accept = "application/vnd.github.hellcat-preview+json"
        try:
            data = await self.api.getitem(self.TEAMS_MEMBERSHIP, var_data, accept=accept)
            if data['state'] == "active":
                return True
        except gidgethub.BadRequest as exc:
            if exc.status_code != 404:
                raise
        return False

    async def is_member(self, username: str, team: Optional[Union[str, int]] = None) -> bool:
        """Check user membership

        Args:
          username: Name of user for whom to check membership
          team: Name, Slug or ID of team to check
        Returns:
          True if the user is member of the organization, and, if **team**
          is provided, if user is member of that team.
        """
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

        if team:
            return await self.is_team_member(username, team)
        return True

    async def search_issues(self, author=None, pr=False, issue=False, sha=None,
                            closed=None):
        """Search issues/PRs on our repos

        Arguments:
          author: login name of user to search
          sha: SHA of commit to search for
          pr: whether to consider only PRs
          issue: whether to consider only non-PR issues
          closed: search only closed if true, only open if false
        """
        query = ["org:" + self.user]

        if pr and not issue:
            query += ["is:pr"]
        elif issue and not pr:
            query += ["is:issue"]

        if closed is not None:
            if closed:
                query += ["is:closed"]
            else:
                query += ["is:open"]

        if author:
            query += ["author:" + author]
        if sha:
            query += ["sha:" + sha]

        return await self.api.getitem(self.SEARCH_ISSUES + '+'.join(query))

    async def get_pr_count(self, user) -> int:
        """Get the number of PRs opened by user

        Arguments:
          user: login of user to query

        Returns:
          Number of PRs that **user** has opened so far
        """
        result = await self.search_issues(pr=True, author=user)
        return result.get('total_count', 0)

    async def is_org(self) -> bool:
        """Check if we are operating on an organization"""
        try:
            await self.api.getitem(self.ORG, self.var_default)
        except gidgethub.BadRequest:
            return False
        return True

    async def get_prs_from_sha(self, head_sha: str, only_open=False) -> List[int]:
        """Searches for PRs matching **head_sha**

        Args:
          head_sha: The head checksum to search for
          only_open: If true, return only open PRs
        Result:
          List of PR numbers.
        """
        pr_numbers = []
        result = await self.search_issues(pr=True, sha=head_sha,
                                          closed=False if only_open else None)
        for pull in result.get('items', []):
            pr_number = int(pull['number'])
            logger.error("checking %s", pr_number)
            full_pr = await self.get_prs(number=pr_number)
            if full_pr['head']['sha'].startswith(head_sha):
                pr_numbers.append(pr_number)
        return pr_numbers

    # pylint: disable=too-many-arguments
    @backoff.on_exception(backoff.fibo, gidgethub.BadRequest, max_tries=10,
                          giveup=lambda ex: ex.status_code not in [429, 502, 503, 504])
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

        accept = "application/vnd.github.shadow-cat-preview"  # for draft
        try:
            return await self.api.getitem(self.PULLS, var_data, accept=accept)
        except gidgethub.BadRequest as exc:
            if exc.status_code == 404:
                if number:
                    return {}
                return []
            raise

    async def get_issue(self, number: int) -> Dict[str, Any]:
        """Retrieve a single PR or Issue by its number

        Arguments:
          number: PR/Issue number
        Returns:
          The dict will contain a 'pull_request' key (containing dict)
          if the Issue is a PR.
        """
        var_data = copy(self.var_default)
        var_data['number'] = str(number)
        return await self.api.getitem(self.ISSUES, var_data)

    async def iter_pr_commits(self, number: int):
        """Create iterator over commits in a PR"""
        var_data = copy(self.var_default)
        var_data['number'] = str(number)
        try:
            async for item in self.api.getiter(self.PULL_COMMITS, var_data):
                yield item
        except gidgethub.GitHubException:
            return

    # pylint: disable=too-many-arguments
    async def create_pr(self, title: str,
                        from_branch: str,
                        from_user: Optional[str] = None,
                        to_branch: Optional[str] = "master",
                        body: Optional[str] = None,
                        maintainer_can_modify: bool = True,
                        draft: bool = False) -> Dict[Any, Any]:
        """Create new PR

        Arguments:
          title: Title of new PR
          from_branch: Name of branch from which PR asks to pull (aka head)
          from_user: Name of user/org in from which to pull
          to_branch: Name of branch into which to pull (aka base, default: master)
          body: Body text of PR
          maintainer_can_modify: Whether to allow maintainer to modify from_branch
          draft: whether PR is draft
        """
        var_data = copy(self.var_default)
        if not from_user:
            from_user = self.username
        data: Dict[str, Any] = {
            'title': title,
            'base' : to_branch,
            'body': body or '',
            'maintainer_can_modify': maintainer_can_modify,
            'draft': draft,
        }

        if from_user and from_user != self.username:
            data['head'] = f"{from_user}:{from_branch}"
        else:
            data['head'] = from_branch

        logger.debug("PR data %s", data)
        if self.dry_run:
            logger.info("Would create PR '%s'", title)
            if title:
                logger.info(" title: %s", title)
            if body:
                logger.info(" body:\n%s\n", body)

            return {'number': -1}
        logger.info("Creating PR '%s'", title)

        accept = "application/vnd.github.shadow-cat-preview"  # for draft
        return await self.api.post(self.PULLS, var_data, data=data, accept=accept)

    async def merge_pr(self, number: int, title: str = None, message: str = None, sha: str = None,
                           method: MergeMethod = MergeMethod.squash) -> Tuple[bool, str]:
        """Merge a PR

        Arguments:
          number: PR Number
          title: Title for the commit message
          message: Message to append to automatic message
          sha: SHA PR head must match
          merge_method: `MergeMethod` to use. Defaults to squash.

        Returns:
          Tuple: True if successful and message
        """
        var_data = copy(self.var_default)
        var_data['number'] = str(number)
        data = {}
        if title:
            data['commit_title'] = title
        if message:
            data['commit_message'] = message
        if sha:
            data['sha'] = sha
        if method:
            data['merge_method'] = method.name

        try:
            res = await self.api.put(self.PULL_MERGE, var_data, data=data)
            return True, res['message']
        except gidgethub.BadRequest as exc:
            if exc.status_code in (405, 409):
                # not allowed / conflict
                return False, exc.args[0]
            raise

    async def pr_is_merged(self, number) -> bool:
        """Checks whether a PR has been merged

        Arguments:
          number: PR Number

        Returns:
          True if the PR has been merged.
        """
        var_data = copy(self.var_default)
        var_data['number'] = str(number)
        try:
            await self.api.getitem(self.PULL_MERGE, var_data)
            return True
        except gidgethub.BadRequest as exc:
            if exc.status_code == 404:
                return False
            raise

    async def pr_update_branch(self, number) -> bool:
        """Updates PR branch

        Merges changes to "base" into "head"
        """
        var_data = copy(self.var_default)
        var_data['number'] = str(number)
        accept = "application/vnd.github.lydian-preview+json"
        try:
            await self.api.put(self.PULL_UPDATE, var_data, accept=accept, data={})
            return True
        except gidgethub.HTTPException as exc:
            if exc.status_code == 202:
                # Usually, we will get our "true" result via this exception.
                # GitHub sends 202 "Accepted" for this API call. Gidgethub raises
                # on anything but 200, 201, 204 (see sansio.py:decipher_response).
                # So we catch and check the status code.
                return True
            logger.exception("pr_update_branch_failed (2). status_code=%s, args=%s",
                             exc.status_code, exc.args)
            return False

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
        res = await self.api.post(self.ISSUE_COMMENTS, var_data, data=data)
        return res['id']

    async def iter_comments(self, number: int) -> List[Dict[str, Any]]:
        """List comments for issue"""
        var_data = copy(self.var_default)
        var_data["number"] = str(number)
        return self.api.getiter(self.ISSUE_COMMENTS, var_data)

    async def update_comment(self, number: int, body: str) -> int:
        """Update issue comment

        Arguments:
          number: Comment number (NOT PR NUMBER!)
          body: Comment content
        """
        var_data = copy(self.var_default)
        var_data["comment_id"] = str(number)
        data = {
            'body': body
        }
        if self.dry_run:
            logger.info("Would update comment %i",  number)
            return -1
        logger.info("Updating comment %i", number)
        res = await self.api.patch(self.COMMENTS, var_data, data=data)
        return res['id']

    async def get_pr_modified_files(self, number: int) -> List[Dict[str, Any]]:
        """Retrieve the list of files modified by the PR

        Arguments:
          number: PR issue number
        """
        var_data = copy(self.var_default)
        var_data["number"] = str(number)
        return await self.api.getitem(self.PULL_FILES, var_data)

    async def create_check_run(self, name: str, head_sha: str,
                               details_url: str = None, external_id: str = None) -> int:
        """Create a check run

        Arguments:
          name: The name of the check, e.g. ``bioconda-test``
          head_sha: The sha of the commit to check
          details_url: URL for "View more details on <App name>" link
          external_id: ID for us

        Returns:
          The ID of the check run.
        """
        var_data = copy(self.var_default)
        data = {
            'name': name,
            'head_sha': head_sha,
        }
        if details_url:
            data['details_url'] = details_url
        if external_id:
            data['external_id'] = external_id

        accept = "application/vnd.github.antiope-preview+json"
        result = await self.api.post(self.CHECK_RUN, var_data, data=data, accept=accept)
        return int(result.get('id'))

    async def modify_check_run(self, number: int,
                               status: CheckRunStatus = None,
                               conclusion: CheckRunConclusion = None,
                               output_title: str = None,
                               output_summary: str = None,
                               output_text: str = None,
                               output_annotations: List[Dict] = None,
                               actions: List[Dict] = None) -> Dict['str', Any]:
        """Modify a check runs

        Arguments:
          number: id number of check run
          status: current status
          conclusion: result of check run, needed if status is completed
          output_title: title string for result window
          output_summary: subtitle/summary string for result window (reqired if title given)
          output_text: Markdown text for result window
          annotations: List of annotated code pieces, each has to have ``path``,
                       ``start_line`` and ``end_line``, ``annotation_level`` (``notice``,
                       ``warning``, ``failure``), and a ``message``. May also have
                       may have ``start_column`` and ``end_column`` (if only one line),
                       ``title`` and ``raw_details``.
          actions: List of up to three "actions" as dict of ``label``, ``description``
                   and ``identifier``
        Returns:
          Check run "object" as dict.
        """
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
                data['output']['annotations'] = output_annotations
        if actions:
            data['actions'] = actions
        accept = "application/vnd.github.antiope-preview+json"
        return await self.api.patch(self.CHECK_RUN, var_data, data=data, accept=accept)

    async def get_check_runs(self, sha: str) -> List[Dict[str, Any]]:
        """List check runs for **sha**

        Arguments:
          sha: The commit SHA for which  to search for check runs
        Returns:
          List of check run "objects"
        """
        var_data = copy(self.var_default)
        var_data['commit'] = sha
        accept = "application/vnd.github.antiope-preview+json"
        res = await self.api.getitem(self.GET_CHECK_RUNS, var_data, accept=accept)
        return res['check_runs']

    async def get_statuses(self, sha: str) -> List[Dict[str, Any]]:
        """List status checks for **sha**

        Arguments:
          sha: The commit SHA for which to find statuses
        Returns:
          List of status "objects"
        """
        var_data = copy(self.var_default)
        var_data['commit'] = sha
        return await self.api.getitem(self.GET_STATUSES, var_data)

    async def get_pr_reviews(self, pr_number: int) -> List[Dict[str, Any]]:
        """Get reviews filed for a PR

        Arguments:
          pr_number: Number of PR
        Returns:
          List of dictionaries each having ``body`` (`str`), ``state`` (`ReviewState`),
          and ``commit_id`` (SHA, `str`) as well as a ``user`` `dict`.
        """
        var_data = copy(self.var_default)
        var_data['number'] = str(pr_number)
        return await self.api.getitem(self.PULL_REVIEWS, var_data)

    async def get_branch_protection(self, branch: str = "master") -> Dict[str, Any]:
        """Retrieve protection settings for branch

        Arguments:
          branch: Branch for which to get protection settings

        Returns:
          Deep dict as example below. Protections not in place will not be present
          in dict.

          .. code-block:: yaml

             required_status_checks:  # require status checks to pass
                 strict: False        # require PR branch to be up to date with base
                 contexts:            # list of status checks required
                    - bioconda-test
                 enforce_admins:      # admins, too, must follow rules
                    - enabled: True
             required_pull_request_reviews:          # require approving review
                 required_approving_review_count: 1  # 1 - 6 valid
                 dismiss_stale_reviews: False        # auto dismiss approval after push
                 require_code_owner_reviews: False
                 dismissal_restrictions:             # specify who may dismiss reviews
                    users:
                      - login: bla
                    teams:
                      - id: 1
                      - name: Bl Ub
                      - slug: bl-ub
             restrictions:             # specify who may push
               users:
                 - login: bla
               teams:
                 - id: 1
             enforce_admins:
               enabled: True  # apply to admins also
        """
        var_data = copy(self.var_default)
        var_data["branch"] = branch
        accept = "application/vnd.github.luke-cage-preview+json"
        res = await self.api.getitem(self.BRANCH_PROTECTION, var_data, accept=accept)
        return res

    async def check_protections(self, pr_number: int,
                                head_sha: str = None) -> Tuple[Optional[bool], str]:
        """Check whether PR meets protection requirements

        Arguments:
          pr_number: issue number of PR
          head_sha: if given, check that this is still the latest sha
        """
        pr = await self.get_prs(number=pr_number)
        logger.info("Checking protections for PR #%s : %s", pr_number, head_sha)

        # check that no new commits were made
        if head_sha and head_sha != pr['head']['sha']:
            return False, "Most recent SHA in PR differs"
        head_sha = pr['head']['sha']
        # check whether it's already merged
        if pr['merged']:
            return False, "PR has already been merged"
        # check whether it's in draft state
        if pr.get('draft'):
            return False, "PR is marked as draft"
        # check whether it's mergeable
        if pr['mergeable'] is None:
            return None, "PR mergability unknown. Retry again later."

        # get required checks for target branch
        protections = await self.get_branch_protection(pr['base']['ref'])

        # Verify required_checks
        required_checks = set(protections.get('required_status_checks', {}).get('contexts', []))
        if required_checks:
            logger.info("Verifying %s required checks", len(required_checks))
            for status in await self.get_statuses(head_sha):
                if status['state'] == 'success':
                    required_checks.discard(status['context'])
            for check in await self.get_check_runs(head_sha):
                if check.get('conclusion') == "success":
                    required_checks.discard(check['name'])
            if required_checks:
                return False, "Not all required checks have passed"
            logger.info("All status checks passed for #%s", pr_number)

        # Verify required reviews
        required_reviews = protections.get('required_pull_request_reviews', {})
        if required_reviews:
            required_count = required_reviews.get('required_approving_review_count', 1)
            logger.info("Checking for %s approvng reviews and no change requests",
                        required_count)
            approving_count = 0
            for review in await self.get_pr_reviews(pr_number):
                user = review['user']['login']
                if review['state'] == ReviewState.CHANGES_REQUESTED.name:
                    return False, f"Changes have been requested by `@{user}`"
                if review['state'] == ReviewState.APPROVED.name:
                    logger.info("PR #%s was approved by @%s", pr_number, user)
                    approving_count += 1
            if approving_count < required_count:
                return False, (f"Insufficient number of approving reviews"
                               f"({approving_count}/{required_count})")
        logger.info("PR #%s is passing configured checks", pr_number)
        return True, "LGTM"

    async def get_contents(self, path: str, ref: str = None) -> str:
        """Get contents of a file in repo

        Arguments:
          path: file path
          ref: git reference (branch, commit, tag)

        Returns:
          The contents of the file

        Raises:
          RuntimeError if the content encoding is not understood.
          (Should always be base64)
        """
        var_data = copy(self.var_default)
        var_data['path'] = path
        if ref:
            var_data['ref'] = ref
        else:
            ref = 'master'
        result = await self.api.getitem(self.CONTENTS, var_data)
        if result['encoding'] != 'base64':
            raise RuntimeError(f"Got unknown encoding for {self}/{path}:{ref}")
        content_bytes = base64.b64decode(result['content'])
        content = content_bytes.decode('utf-8')
        return content

    async def delete_branch(self, ref: str) -> None:
        """Delete a branch (ref)

        Arguments:
          ref: Name of reference/branch
        """
        var_data = copy(self.var_default)
        var_data['ref'] = ref
        await self.api.delete(self.GIT_REFERENCE, var_data)

    def _deparse_card_pr_number(self, card: Dict[str, Any]) -> Dict[str, Any]:
        """Extracts the card's issue's number from the content_url

        This is a hack. The card data returned from github does not contain
        content_id or anything referencing the PR/issue except for the
        content_url. We deparse this here manually.

        Arguments:
          card: Card dict as returned from github
        Results:
          Card dict with ``issue_number`` field added if card is not a note
        """
        if 'content_url' not in card:  # not content_url to parse
            return card
        if 'issue_number' in card:  # target value already taken
            return card

        issue_url = gidgethub.sansio.format_url(self.ISSUES, self.var_default)
        content_url = card['content_url']
        if content_url.startswith(issue_url):
            try:
                card['issue_number'] = int(content_url.lstrip(issue_url))
            except ValueError:
                pass
        if 'issue_number' not in card:
            logger.error("Failed to deparse content url to issue number.\n"
                         "content_url=%s\nissue_url=%s\n",
                         content_url, issue_url)
        return card

    async def list_project_cards(self, column_id: int) -> List[Dict[str, Any]]:
        """List cards in a project column

        Arguments:
          column_id: ID number of project column
        """
        var_data = {'column_id': str(column_id)}
        accept = "application/vnd.github.inertia-preview+json"
        res = await self.api.getitem(self.PROJECT_COL_CARDS, var_data, accept=accept)
        return [self._deparse_card_pr_number(card) for card in res]

    async def get_project_card(self, card_id: int) -> Dict[str, Any]:
        """Get a project card

        Arguments:
          card_id: ID number of project card
        Returns:
          Empty dict if the project card was not found
        """
        var_data = {'card_id': str(card_id)}
        accept = "application/vnd.github.inertia-preview+json"
        try:
            res = await self.api.getitem(self.PROJECT_CARDS, var_data, accept=accept)
        except gidgethub.BadRequest as exc:
            if exc.status_code == 404:
                return {}
        return self._deparse_card_pr_number(res)

    async def create_project_card(self, column_id: int,
                                  note: str = None,
                                  content_id: int = None,
                                  content_type: CardContentType = None,
                                  number: int = None) -> Dict[str, Any]:
        """Create a new project card

        In addition to **column_id**, you must provide *either*:
        - The **note** parameter for a free text note card
        - The **content_type** specifying whether the card references a PR or an Issue,
          *and* the **content_id** with the **id** field from the PR or Issue. Note that
          PRs have two IDs, once as their issue baseclass and once as PR. You must use
          the latter for PRs.
        - The **number** giving either PR or Issue number. Will trigger one or two extra
          API calls to fill in the **content_type** and **content_id** fields.

        Arguments:
          column_id: The ID number of the project column
          note: Content of a note card.
          content_id: ID number of PR or Issue
          content_type: Must match content_id type
          number: PR or Issue number
        Returns:
          Dict describing newly created card. Empty if no card.

        """
        var_data = copy(self.var_default)
        var_data['column_id'] = str(column_id)
        accept = "application/vnd.github.inertia-preview+json"
        data = {}
        if note:
            if content_id or content_type or number:
                raise ValueError("Project Cards can only be a note or a Issue/PR")
            data['note'] = note
        elif content_id:
            if number:
                raise ValueError("Cannot specify pr/issue number AND content_id")
            if not content_type:
                raise ValueError("Must specify content_type if giving content_id")
            data['content_id'] = content_id
            data['content_type'] = content_type.name
        elif number:
            pullreq = await self.get_prs(number=number)
            if pullreq:
                data['content_id'] = pullreq['id']
                data['content_type'] = CardContentType.PullRequest.name
            else:
                issue = await self.get_issue(number=number)
                data['content_id'] = issue['id']
                data['content_type'] = CardContentType.Issue.name
        else:
            raise ValueError("Must have at least note or content_id/content_type or "
                             "number parameter")
        try:
            res = await self.api.post(self.PROJECT_COL_CARDS, var_data, data=data,
                                       accept=accept)
            return self._deparse_card_pr_number(res)
        except gidgethub.BadRequest:
            logger.exception("Failed to create project card with data=%s", data)
            return {}

    async def delete_project_card(self, card_id: int) -> bool:
        """Deletes a project card

        Arguments:
          card_id: ID of the card to delete
        Returns:
          True if the deletion succeeded
        """
        var_data = {'card_id': str(card_id)}
        accept = "application/vnd.github.inertia-preview+json"
        try:
            await self.api.delete(self.PROJECT_CARDS, var_data, accept=accept)
            return True
        except gidgethub.BadRequest:
            logger.exception("Failed to delete project cards %s", card_id)
            return False

    async def delete_project_card_from_column(self, column_id: int, number: int) -> bool:
        """Deletes a project card identified by PR/Issue number from column

        Arguments:
          column_id: ID of project card column
          number: PR/Issue number
        Returns:
          True if the deleteion succeeded
        """
        for card in await self.list_project_cards(column_id):
            if card.get('issue_number') == number:
                return await self.delete_project_card(card['id'])
        return False


class AiohttpGitHubHandler(GitHubHandler):
    """GitHubHandler using Aiohttp for HTTP requests

    Arguments:
      session: Aiohttp Client Session object
      requester: Identify self (e.g. user agent)
    """
    def create_api_object(self, session: aiohttp.ClientSession,
                          requester: str, *args, **kwargs) -> None:
        self.api = gidgethub.aiohttp.GitHubAPI(
            session, requester, oauth_token=self.token,
            cache=cachetools.LRUCache(maxsize=500)
        )
        self.session = session


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
    """Handles interaction with Github as App

    Arguments:
      session: Use this session to make calls to the Github API
      app_name: The name of the App. This is also used as HTTP user agent
                identifier.
      app_key: A PEM key used to sign JWT to obtain temporary bearer tokens
               for accessing the Github API.
      app_id: This number identifies our App at Github.
      client_id: This number identifies our App at Github when logging in
                 on behalf of users via OAUTH.
      client_secret: The secret authenticating us when logging in on behalf
                     of users via OAUTH

    """
    #: Github API url for creating an access token for a specific installation
    #: of an app.
    INSTALLATION_TOKEN = "/app/installations/{installation_id}/access_tokens"

    #: Get installation info
    INSTALLATION = "/repos/{owner}/{repo}/installation"

    #: Lifetime of JWT in seconds
    JWT_RENEW_PERIOD = 600

    #: Base URL for calls to oauth login
    DOMAIN = "https://github.com"

    #: URL template for calls to OAUTH authorize
    AUTHORIZE = '/login/oauth/authorize{?client_id,client_secret,redirect_uri,state,login}'

    #: URL templete for calls to OAUTH access_token
    ACCESS_TOKEN = '/login/oauth/access_token'

    def __init__(self, session: aiohttp.ClientSession,
                 app_name: str, app_key: str, app_id: str,
                 client_id: str, client_secret: str) -> None:
        #: Name of app
        self.name = app_name
        #: ID of app
        self.app_id = app_id
        #: Authorization key
        self.app_key = app_key
        #: OAUTH client ID
        self.client_id = client_id
        #: OAUTH client secret
        self.client_secret = client_secret
        #: Cache for API queries
        self._cache = cachetools.LRUCache(maxsize=500)
        #: Our client session
        self._session = session
        #: JWT and its expiry
        self._jwt: Tuple[int, str] = (0, "")
        #: OAUTH tokens for installations
        self._tokens: Dict[str, Tuple[int, str]] = {}
        #: GitHubHandlers for each installation
        self._handlers: Dict[Tuple[str, str], GitHubHandler] = {}


    def get_app_jwt(self) -> str:
        """Returns JWT authenticating as this app"""
        now = int(time.time())
        expires, token = self._jwt
        if not expires or expires < now + 60:
            expires = now + self.JWT_RENEW_PERIOD
            payload = {
                'iat': now,
                'exp': expires,
                'iss': self.app_id,
            }
            token_utf8 = jwt.encode(payload, self.app_key, algorithm="RS256")
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
            api = gidgethub.aiohttp.GitHubAPI(self._session, self.name, cache=self._cache)
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

    async def get_installation_id(self, user, repo):
        """Retrieve installation ID given user and repo"""
        api = gidgethub.aiohttp.GitHubAPI(self._session, self.name, cache=self._cache)
        res = await api.getitem(self.INSTALLATION,
                                {'owner': user, 'repo': repo},
                                accept="application/vnd.github.machine-man-preview+json",
                                jwt=self.get_app_jwt())
        return res['id']

    async def get_github_api(self, dry_run, to_user, to_repo, installation=None) -> GitHubHandler:
        """Returns the GitHubHandler for the installation the event came from"""
        if installation is None:
            installation = await self.get_installation_id(to_user, to_repo)

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


    @staticmethod
    def generate_nonce(nbytes=16):
        """Generates a random string

        Fetches **nbytes** of random data from `os.urandom` and passes them through
        base64 encoding.
        """
        return base64.b64encode(os.urandom(nbytes), altchars=b'_-').decode()

    async def oauth_github_user(self, redirect, session, params):
        """Acquires `AiohttpGitHubHandler` for user via OAuth

        This must be called from an ``aiohttp.web`` server with the
        ``aiohttp-session`` active for session management.

        If the user was not yet logged in (has no token in the
        session), this will raise a `web.HTTPFound` exception to
        redirect the user's browser to Github where the app can be
        authorized to act on the users behalf. If the user OKs this,
        Github redirects the user back to the URL given in
        **redirect**. The code behind that URL should call this
        function again, passing the parameters from Github. Using
        those parameters, an OAUTH token is acquired, used to create
        an `AiohttpGitHubHandler` object and that object initilized to
        fetch the users details (calling ``login`` to acquire user
        name and avatar).

        Details:
          Two parameters are passed through the redirect calls. The
          **state** parameter is a nonce generated to avoid cross-site
          request forgery. It is stored in the users session and must
          be passed back identically on the second call. The **code**
          parameter is the secret used to acquire the OAUTH token on
          the second call to this method.

          Two values are stored in the user's session. The nonce
          mentioned above and the OAUTH token. A short path attempts
          to use an existing token to re-authenticate an already
          logged in user.

        Arguments:
          redirect: URL to redirect to for authentication callback.
                    Usually, this is the URL from which you called
                    this function, so that it gets called again with
                    the parameters send by GitHub.
          session: Session for making calls to Github API
          params: URL parameters that were sent by GitHub.

        Returns:
          The API client object with the user logged in.

        """

        nonce_cookie_name = f'{self.__class__.__name__}::nonce'
        token_cookie_name = f'{self.__class__.__name__}::token'

        code = params.get('code')
        state = params.get('state')
        nonce = session.get(nonce_cookie_name)

        # If we have a token already, try to authenticate the user
        # with this token.
        if token_cookie_name in session:
            handler = AiohttpGitHubHandler(token=session.get(token_cookie_name))
            if await handler.login(self._session, self.name):
                return handler

        # First pass. We don't have a code yet, or the state does
        # not match our nonce (usually if a user calls the login url
        # from the browser history). Redirect to GitHub for authentication.
        if not code or state != nonce:
            nonce = self.generate_nonce()
            session[nonce_cookie_name] = nonce
            raise aiohttp.web.HTTPFound(uritemplate.expand(
                self.DOMAIN + self.AUTHORIZE, {
                    'client_id': self.client_id,
                    'redirect_uri': redirect,
                    'state': nonce,
                }))

        # Second pass. We have a code and the state matched the nonce.
        # Fetch the OAUTH token from Github using the code and state.
        data = {'client_id': self.client_id,
                'client_secret': self.client_secret,
                'code': code,
                'state': nonce}
        headers = {'Accept': 'application/json'}
        async with self._session.post(self.DOMAIN + self.ACCESS_TOKEN,
                                      json=data, headers=headers) as response:
            response.raise_for_status()
            result = await response.json()

        # We should always get a bearer token. This seems to be a future
        # extension. Check it anyway:
        if result.get('token_type') != 'bearer':
            raise RuntimeError("Token type not 'bearer'")

        # Create the client and get user details to verify token validity
        handler = AiohttpGitHubHandler(token=result.get('access_token'))
        if not await handler.login(self._session, self.name):
            raise RuntimeError("Failed to login")
        session[token_cookie_name] = handler.token

        return handler
