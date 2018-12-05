import os
import sys
from collections import defaultdict, namedtuple

import numpy as np
import pandas as pd
import requests
from conda.exports import VersionOrder

from .utils import PackageKey, PackageBuild


REPODATA_URL = 'https://conda.anaconda.org/{channel}/{subdir}/repodata.json'
REPODATA_LABELED_URL = 'https://conda.anaconda.org/{channel}/label/{label}/{subdir}/repodata.json'
REPODATA_DEFAULTS_URL = 'https://repo.anaconda.com/pkgs/main/{subdir}/repodata.json'

def platform2subdir(platform):
    if platform == 'linux':
        return 'linux-64'
    elif platform == 'osx':
        return 'osx-64'
    elif platform == 'noarch':
        return 'noarch'
    else:
        raise ValueError(
            'Unsupported platform: bioconda only supports linux, osx and noarch.')

def _get_channel_repodata(channel, platform):
    """
    Returns the parsed JSON repodata for a channel from conda.anaconda.org.

    A dicts is containing the repodata is returned.

    Parameters
    ----------
    channel : str
        Channel to retrieve packages for

    platform : noarch | linux | osx
        Platform (OS) to retrieve packages for from `channel`.
    """

    if channel == "defaults":
        # caveat: this only gets defaults main, not 'free', 'r' or 'pro'
        url_template = REPODATA_DEFAULTS_URL
    else:
        url_template = REPODATA_URL

    url = url_template.format(channel=channel,
                              subdir=platform2subdir(platform))
    repodata = requests.get(url)
    if repodata.status_code != 200:
        raise requests.HTTPError(
            '{0.status_code} {0.reason} for {1}'
            .format(repodata, url))

    return repodata.json()


def _get_native_platform():
    if sys.platform.startswith("linux"):
        return "linux"
    if sys.platform.startswith("darwin"):
        return "osx"
    raise ValueError("Running on unsupported platform")


def get_all_channel_packages(channels):
    """
    Return a PackageKey -> set(PackageBuild) mapping.

    That is: (name, version, build_number) -> Set[(subdir, build)]
    """
    if channels is None:
        channels = []
    platform = _get_native_platform()

    channel_packages = defaultdict(set)
    for channel in channels:
        for arch in (platform, "noarch"):
            repo = _get_channel_repodata(channel, arch)
            subdir = repo['info']['subdir']
            for package in repo['packages'].values():
                pkg_key = PackageKey(package['name'], package['version'],
                                     package['build_number'])
                pkg_build = PackageBuild(subdir, package['build'])
                channel_packages[pkg_key].add(pkg_build)
    channel_packages.default_factory = None
    return channel_packages


# called from bioconductor_skeleton, cli
def get_packages(channels):
    """
    Generates list of packages in channels

    Args:
      channels: string or list of string
    """
    if isinstance(channels, str):
        channels = [channels]
    platform = _get_native_platform()
    for channel in channels:
        for arch in (platform, 'noarch'):
            repo = _get_channel_repodata(channel, arch)
            for pkg in repo['packages'].values():
                yield pkg


class RepoData:
    """Singleton providing access to package directory on anaconda cloud

    If the first call provides a filename as **cache** argument, the
    file is used to cache the directory in CSV format.

    Data structure:

    Each **channel** hosted at anaconda cloud comprises a number of
    **subdirs** in which the individual package files reside. The
    **subdirs** can be one of **noarch**, **osx-64** and **linux-64**
    for Bioconda. (Technically ``(noarch|(linux|osx|win)-(64|32))``
    appears to be the schema).

    For **channel/subdir** (aka **channel/platform**) combination, a
    **repodata.json** contains a **package** key describing each
    package file with at least the following information:

    name: Package name (lowercase, alphanumeric + dash)

    version: Version (no dash, PEP440)

    build_number: Non negative integer indicating packaging revisions

    build: String comprising hash of pinned dependencies and build
      number. Used to distinguish different builds of the same
      package/version combination.

    depends: Runtime requirements for package as list of strings. We
      do not currently load this.

    arch: Architecture key (x86_64). Not used by conda and not loaded
      here.

    platform: Platform of package (osx, linux, noarch). Optional
      upstream, not used by conda. We generate this from the subdir
      information to have it available.


    Repodata versions:

    The version is indicated by the key **repodata_version**, with
    absence of that key indication version 0.

    In version 0, the **info** key contains the **subdir**,
    **platform**, **arch**, **default_python_version** and
    **default_numpy_version** keys. In version 1 it only contains the
    **subdir** key.

    In version 1, a key **removed** was added, listing packages
    removed from the repository.

    """

    _load_columns = ['build', 'build_number', 'name', 'version']

    #: Columns available in internal dataframe
    columns = _load_columns + ['channel', 'subdir', 'platform']
    #: Platforms loaded
    platforms = ['linux', 'osx', 'noarch']
    #: Channels loaded
    channels = ['conda-forge', 'bioconda', 'defaults']

    __instance = None
    def __new__(cls):
        """Makes RepoData a singleton"""
        if RepoData.__instance is None:
            RepoData.__instance = object.__new__(cls)
        return RepoData.__instance

    def __init__(self, cache=None):
        if cache is not None and os.path.exists(cache):
            self.df = pd.read_table(cache)
            return

        # Get the channel data into a big dataframe
        dfs = []
        for platform in self.platforms:
            for channel in self.channels:
                repo = _get_channel_repodata(channel, platform)
                df = pd.DataFrame.from_dict(repo['packages'], 'index',
                                            columns=self._load_columns)
                df['channel'] = channel
                df['platform'] = platform
                df['subdir'] = repo['info']['subdir']
                dfs.append(df)

        self.df = pd.concat(dfs)

        if cache is not None:
            self.df.to_csv(cache, sep='\t')

    def get_versions(self, p):
        # called from doc generator
        """Get versions available for package

        Args:
          p: package name

        Returns:
          Dictionary mapping version numbers to list of architectures
        """
        # get dataframe: (filename) x (version, platform)
        packages = self.df[self.df.name == p][['version', 'platform']]
        # merge rows with same version, making platform distinct list
        versions = packages.groupby('version').agg(lambda x: list(set(x)))
        # return dict from platform column
        # e.g. {'0.1': ['linux'], '0.2': ['linux', 'osx'], '0.3': ['noarch']}
        return versions['platform'].to_dict()

    def get_channels(self, name, version=None, build_number=None):
        # called from lint functions
        selection = self.df.name == name
        if version:
            selection &= self.df.version == version
        if build_number:
            selection &= self.df.build_number == build_number
        packages = self.df[selection]
        return set(packages.channel)

    def get_latest_versions(self, channel):
        # called from pypi module
        packages = self.df[self.df.channel == channel]['version']
        def max_vers(x):
            return max(VersionOrder(v) for v in x)
        vers = packages.groupby('name').agg(max_vers)


