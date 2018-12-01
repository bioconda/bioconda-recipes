import os
import sys
from collections import defaultdict, namedtuple

import numpy as np
import pandas as pd
import requests

from .utils import PackageKey, PackageBuild

def get_channel_repodata(channel='bioconda', platform=None):
    """
    Returns the parsed JSON repodata for a channel from conda.anaconda.org.

    A tuple of dicts is returned, (repodata, noarch_repodata). The first is the
    repodata for the provided platform, and the second is the noarch repodata,
    which will be the same for a channel no matter what the platform.

    Parameters
    ----------
    channel : str
        Channel to retrieve packages for

    platform : None | linux | osx
        Platform (OS) to retrieve packages for from `channel`. If None, use the
        currently-detected platform.
    """
    url_template = 'https://conda.anaconda.org/{channel}/{arch}/repodata.json'
    if (
        (platform == 'linux') or
        (platform is None and sys.platform.startswith("linux"))
    ):
        arch = 'linux-64'
    elif (
        (platform == 'osx') or
        (platform is None and sys.platform.startswith("darwin"))
    ):
        arch = 'osx-64'
    else:
        raise ValueError(
            'Unsupported OS: bioconda only supports linux and osx.')

    url = url_template.format(channel=channel, arch=arch)
    repodata = requests.get(url)
    if repodata.status_code != 200:
        raise requests.HTTPError(
            '{0.status_code} {0.reason} for {1}'
            .format(repodata, url))

    noarch_url = url_template.format(channel=channel, arch='noarch')
    noarch_repodata = requests.get(noarch_url)
    if noarch_repodata.status_code != 200:
        raise requests.HTTPError(
            '{0.status_code} {0.reason} for {1}'
            .format(noarch_repodata, noarch_url))
    return repodata.json(), noarch_repodata.json()


def get_channel_packages(channel='bioconda', platform=None):
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
    repodata, noarch_repodata = get_channel_repodata(
        channel=channel, platform=platform)
    channel_packages = defaultdict(set)
    for repo in (repodata, noarch_repodata):
        subdir = repo['info']['subdir']
        for package in repo['packages'].values():
            pkg_key = PackageKey(
                package['name'], package['version'], package['build_number'])
            pkg_build = PackageBuild(subdir, package['build'])
            channel_packages[pkg_key].add(pkg_build)
    channel_packages.default_factory = None
    return channel_packages


def get_all_channel_packages(channels):
    """
    Return a PackageKey -> set(PackageBuild) mapping.
    """
    if channels is None:
        channels = []

    all_channel_packages = defaultdict(set)
    for channel in channels:
        channel_packages = get_channel_packages(channel=channel)
        for pkg_key, pkg_builds in channel_packages.items():
            all_channel_packages[pkg_key].update(pkg_builds)
    all_channel_packages.default_factory = None
    return all_channel_packages


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
    if cache is not None and os.path.exists(cache):
        df = pd.read_table(cache)
    else:
        # Get the channel data into a big dataframe
        dfs = []
        for platform in ['linux', 'osx']:
            for channel in channels:
                repo, noarch = get_channel_repodata(channel, platform)
                x = pd.DataFrame(repo)
                x = x.drop([
                    'arch',
                    'default_numpy_version',
                    'default_python_version',
                    'platform',
                    'subdir'])
                for k in [
                    'build', 'build_number', 'name', 'version', 'license',
                    'platform'
                ]:
                    x[k] = x['packages'].apply(lambda y: y.get(k, np.nan))

                x['channel'] = channel
                dfs.append(x)

        df = pd.concat(dfs).drop(['info', 'packages'], axis=1)

        if cache is not None:
            df.to_csv(cache, sep='\t')
    return df
