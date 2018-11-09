"""Abstraction layer handling git actions"""

import asyncio
import logging
import os

from itertools import chain

import git

logger = logging.getLogger(__name__)  # pylint: disable=invalid-name


class GitHandler():
    """GitPython abstraction

    Arguments:
      recipe_folder: Base folder containing recipes (needed to determine
                     location of git repo).
      dry_run: Don't push anything to remote
    """
    def __init__(self, recipe_folder, dry_run=False,
                 upstream='bioconda/bioconda-recipe', origin='origin'):
        #: current repository
        self.repo = git.Repo(recipe_folder, search_parent_directories=True)
        if self.repo.is_dirty():
            raise RuntimeError("Repository is in dirty state. Bailing out")

        abs_recipe_folder = os.path.abspath(recipe_folder)
        abs_repo_root = os.path.abspath(self.repo.working_dir)

        #: recipe folder relative to git root
        self.rel_recipe_folder = abs_recipe_folder[len(abs_repo_root):].lstrip("/")
        #: don't push
        self.dry_run = dry_run
        #: Semaphore for things that mess with workding directory
        self.lock_working_dir = asyncio.Semaphore(1)
        #: Remote upstream (for pulling)
        self.upstream = self.get_remote(upstream)
        self.upstream.fetch(prune=True)
        logger.warning("Pulling from %s (%s)", self.upstream.name, ",".join(self.upstream.urls))
        #: Remote origin (for pushing)
        self.origin = self.get_remote(origin)
        self.origin.fetch(prune=True)
        logger.warning("Pushing to %s (%s)", self.origin.name, ",".join(self.origin.urls))
        #: Branch to restore after running
        self.prev_active_branch = self.repo.active_branch
        #: Master
        self.master = self.get_local_branch("master")
        logger.warning("Checking out master")
        self.master.checkout()
        logger.info("Updating master from upstream")
        self.upstream.pull("master")

        #: commit from which branches should derive
        self.from_commit = self.upstream.fetch('master')[0].commit

    def get_remote(self, desc):
        """Finds first remote containing **desc** in one of its URLs"""
        if desc in [r.name for r in self.repo.remotes]:
            return self.repo.remotes[desc]
        remotes = [r for r in self.repo.remotes
                   if any(filter(lambda x: desc in x, r.urls))]
        if not remotes:
            raise KeyError(f"No remote matching '{desc}' found")
        return remotes[0]

    async def branch_is_current(self, branch, path, master="master"):
        """Checks if **branch** has the most recent commit modifying **path**
        as compared to **master**"""
        rpath = os.path.join(self.rel_recipe_folder, path)
        proc = await asyncio.create_subprocess_exec(
            'git', 'log', '-1', '--oneline', '--decorate',
            f'{master}...{branch.name}', '--', rpath,
            stdout=asyncio.subprocess.PIPE)
        stdout, _ = await proc.communicate()
        return branch.name in stdout.decode('ascii')

    def delete_local_branch(self, branch):
        """Deletes **branch** locally"""
        git.Reference.delete(self.repo, branch)

    def delete_remote_branch(self, branch_name):
        """Deletes **branch** on remote"""
        if not self.dry_run:
            logger.info("Deleting branch %s", branch_name)
            self.origin.push(":" + branch_name)
        else:
            logger.info("Would delete branch %s", branch_name)

    def list_branches(self, branch_prefix):
        """Get list of branch names starting with **branch_prefix** including
        both those from local and from remote/origin"""
        return list(set(
            branch.name
            for branch in chain(self.repo.branches,
                                self.origin.refs)
            if branch.name.startswith(branch_prefix)
        ))

    def get_local_branch(self, branch_name: str):
        """Finds local branch named **branch_name**"""
        if branch_name in self.repo.branches:
            return self.repo.branches[branch_name]
        return None

    def get_remote_branch(self, branch_name: str):
        """Finds remote (origin) branch named **branch_name**"""
        if branch_name in self.origin.refs:
            return self.origin.refs[branch_name]
        return None

    def read_from_branch(self, branch, file_name: str) -> str:
        """Reads contents of file **file_name** from git branch **branch**"""
        abs_file_name = os.path.abspath(file_name)
        abs_repo_root = os.path.abspath(self.repo.working_dir)
        if not abs_file_name.startswith(abs_repo_root):
            raise RuntimeError(
                f"File {abs_file_name} not inside {abs_repo_root}"
            )
        rel_file_name = abs_file_name[len(abs_repo_root):].lstrip("/")
        return (branch.commit.tree / rel_file_name).data_stream.read().decode("utf-8")

    def create_local_branch(self, branch_name):
        """Creates local branch from remote **branch_name**"""
        remote_branch = self.get_remote_branch(branch_name)
        self.repo.create_head(branch_name, remote_branch.commit)
        return self.get_local_branch(branch_name)

    def prepare_branch(self, branch_name):
        """Checks out **branch_name**, creating it from master if needed"""
        if branch_name not in self.repo.heads:
            logger.info("Creating new branch %s", branch_name)
            self.repo.create_head(branch_name, self.from_commit)
        logger.info("Checking out branch %s", branch_name)
        branch = self.repo.heads[branch_name]
        branch.checkout()
        self.upstream.pull("master")

    def commit_and_push_changes(self, recipe, branch_name) -> bool:
        """Create recipe commit and pushes to upstream remote

        Returns:
          Boolean indicating whether there were changes committed
        """
        self.repo.index.add([recipe.path])
        if not self.repo.index.diff("HEAD"):
            return False
        self.repo.index.commit(f"Update {recipe} to {recipe.version}")
        if not self.dry_run:
            logger.info("Pushing branch %s", branch_name)
            self.repo.remotes["origin"].push(branch_name)
        else:
            logger.info("Would push branch %s", branch_name)
        return True

    def close(self):
        """Release resources allocated"""
        logger.warning("Switching back to %s", self.prev_active_branch.name)
        self.prev_active_branch.checkout()

        self.repo.close()


