import os
import sys
from collections import defaultdict, namedtuple

import numpy as np
import pandas as pd
import requests

from .utils import PackageKey, PackageBuild


REPODATA_URL = 'https://conda.anaconda.org/{channel}/{arch}/repodata.json'
REPODATA_DEFAULTS_URL = 'https://repo.anaconda.com/pkgs/main/{arch}/repodata.json'


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
    if platform == 'linux':
        arch = 'linux-64'
    elif platform == 'osx':
        arch = 'osx-64'
    elif platform == 'noarch':
        arch = 'noarch'
    else:
        raise ValueError(
            'Unsupported platform: bioconda only supports linux, osx and noarch.')

    if channel == "defaults":
        # caveat: this only gets defaults main, not 'free', 'r' or 'pro'
        url_template = REPODATA_DEFAULTS_URL
    else:
        url_template = REPODATA_URL

    url = url_template.format(channel=channel, arch=arch)
    repodata = requests.get(url)
    if repodata.status_code != 200:
        raise requests.HTTPError(
            '{0.status_code} {0.reason} for {1}'
            .format(repodata, url))

    return repodata.json()


def _get_channel_packages(channel, platform):
    """
    Return a PackageKey -> set(PackageBuild) mapping.
    Retrieves the existing packages for a channel from conda.anaconda.org.

    Parameters
    ----------
    channel : str
        Channel to retrieve packages for

    platform : None | linux | osx
        Platform (OS) to retrieve packages for from `channel`. If None, use the
        currently-detected platform.
    """
    channel_packages = defaultdict(set)
    for arch in (platform, "noarch"):
        repo = _get_channel_repodata(channel, arch)
        subdir = repo['info']['subdir']
        for package in repo['packages'].values():
            pkg_key = PackageKey(
                package['name'], package['version'], package['build_number'])
            pkg_build = PackageBuild(subdir, package['build'])
            channel_packages[pkg_key].add(pkg_build)
    channel_packages.default_factory = None
    return channel_packages


def _get_native_platform():
    if sys.platform.startswith("linux"):
        return "linux"
    if sys.platform.startswith("darwin"):
        return "osx"
    raise ValueError("Running on unsupported platform")


class RepoData(object):
    """Load and parse packages (not recipes) available via channel"""
    def __init__(self):
        logger.info('Loading packages...')
        repodata = defaultdict(lambda: defaultdict(list))
        for platform in ['linux', 'osx']:
            channel_packages = _get_channel_packages('bioconda', platform)
            for pkg_key in channel_packages.keys():
                repodata[pkg_key.name][pkg_key.version].append(platform)
        self.repodata = repodata
        # e.g., repodata = {
        #   'package1': {
        #       '0.1': ['linux'],
        #       '0.2': ['linux', 'osx'],
        #   },
        # }

    def get_versions(self, p):
        """Get versions available for package

        Args:
          p: package name

        Returns:
          Dictionary mapping version numbers to list of architectures
        """
        return self.repodata[p]


# called from build
def get_all_channel_packages(channels):
    """
    Return a PackageKey -> set(PackageBuild) mapping.
    """
    if channels is None:
        channels = []
    platform = _get_native_platform()

    all_channel_packages = defaultdict(set)
    for channel in channels:
        channel_packages = _get_channel_packages(channel, platform)
        for pkg_key, pkg_builds in channel_packages.items():
            all_channel_packages[pkg_key].update(pkg_builds)
    all_channel_packages.default_factory = None
    return all_channel_packages


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
            for pkg in repodata['packages'].values():
                yield pkg


# called from
# build   - gets only conda-forge, defaults to use for linting
# cli     - only with cache in lint, then () in build
# linting only subsets as df[df.name==name & df.version==version] to look at once recipe
# at a time, then checks if any of the result lines have 'bioconda' in row.channel
# or subsets further with df.build_number == build_number and checks if in bioconda
def channel_dataframe(cache=None, channels=['bioconda', 'conda-forge',
                                            'defaults']):
    """
    Return channel info as a dataframe.

    Parameters
    ----------

    cache : str
        Filename of cached channel info

    channels : list
        Channels to include in the dataframe
    """

    columns = ['build', 'build_number', 'name', 'version', 'license',
               'platform']

    if cache is not None and os.path.exists(cache):
        df = pd.read_table(cache)
    else:
        # Get the channel data into a big dataframe
        dfs = []
        for platform in ['linux', 'osx', 'noarch']:
            for channel in channels:
                repo = _get_channel_repodata(channel, platform)
                x = pd.DataFrame.from_dict(repo['packages'], 'index', columns=columns)
                x['channel'] = channel
                dfs.append(x)

        df = pd.concat(dfs)

        if cache is not None:
            df.to_csv(cache, sep='\t')
    return df
