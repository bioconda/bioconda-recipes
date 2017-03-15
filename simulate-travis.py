#!/usr/bin/env python

import os
import platform
import sys
import ruamel_yaml as yaml
import subprocess as sp
import shlex
import argparse

import conda.fetch


usage = """

This script simulates a travis-ci run on the local machine by using the current
values in .travis.yml. It is intended to be run in the top-level directory of
the bioconda-recipes repository.

Any additional arguments to this script are interpreted as arguments to be
passed to `bioconda-utils build`. For example, to build a single recipe (or
glob of recipes):

    simulate-travis.py --packages mypackagename bioconductor-*

or modify the log level:

    simulate-travis.py --packages mypackagename --loglevel=debug

Notes
-----

Any environmental variables will be passed to `scripts/travis-run.sh` and will
override any defaults detected in .travis.yml. Currently the only variables
useful to modify are TRAVIS_OS_NAME and BIOCONDA_UTILS_TAG.  For example you
can set TRAVIS_OS_NAME to "linux" while running on a Mac to build packages in
a docker container:

    TRAVIS_OS_NAME=linux ./simulate-travis.py

Or specify a different commit of `bioconda_utils`:

    BIOCONDA_UTILS_TAG=63543b34 ./simulate-travis.py

"""

ap = argparse.ArgumentParser(usage=usage)
ap.add_argument('--install-requirements', action='store_true', help='''Install
                the currently-configured version of bioconda-utils and its
                dependencies, and then exit.''')
ap.add_argument('--set-channel-order', action='store_true', help='''Set the
                correct channel priorities, and then exit''')
ap.add_argument('--config-from-github', action='store_true', help='''Download
                and use the config.yml and .travis.yml files from the master
                branch of the github repo. Default is to use the files
                currently on disk.''')
ap.add_argument('--disable-docker', action='store_true', help='''By default, if
                the OS is linux then we use Docker. Use this argument to
                disable this behavior''')
args, extra = ap.parse_known_args()

HERE = os.path.abspath(os.path.dirname(__file__))


def _remote_or_local(fn, branch='master', remote=False):
    """
    Downloads a temp file directly from the specified github branch or
    the current one on disk.
    """
    if remote:
        url = (
            'https://raw.githubusercontent.com/bioconda/bioconda-recipes/'
            '{branch}/{path}'.format(branch=branch, path=fn)
        )
        print('Using config file {}'.format(url))
        with conda.fetch.TmpDownload(url) as f:
            cfg = yaml.load(open(f))
    else:
        cfg = yaml.load(open(os.path.join(HERE, fn)))
    return cfg

travis_config = _remote_or_local('.travis.yml', remote=args.config_from_github)
bioconda_utils_config = _remote_or_local('config.yml', remote=args.config_from_github)

env = {}
for var in travis_config['env']['global']:
    if isinstance(var, dict) and list(var.keys()) == ['secure']:
        continue
    name, value = var.split('=', 1)
    env[name] = value


if args.set_channel_order:
    channels = bioconda_utils_config['channels']
    print("""
          Warnings like "'conda-forge' already in 'channels' list, moving to the top"
          are expected if channels have been added before, and can be safely ignored.
          """)

    # The config (and .condarc) expect that higher-priority channels are listed
    # first, but when using `conda config --add` they should be added from
    # lowest to highest priority.
    for channel in channels[::-1]:
        sp.run(['conda', 'config', '--add', 'channels', channel], check=True)
    print("\nconda config is now:\n")
    sp.run(['conda', 'config', '--get'])
    sys.exit(0)

if args.install_requirements:
    sp.run(
        [
            'conda', 'install', '-y', '--file',
            'https://raw.githubusercontent.com/bioconda/bioconda-utils/'
            '{0}/bioconda_utils/bioconda_utils-requirements.txt'.format(env['BIOCONDA_UTILS_TAG'])
        ], check=True)

    sp.run(
        [
            'pip', 'install',
            'git+https://github.com/bioconda/bioconda-utils.git@{0}'.format(env['BIOCONDA_UTILS_TAG'])
        ],
        check=True)
    sys.exit(0)

# Only run if we're not on travis.
if os.environ.get('TRAVIS', None) != 'true':

    # SUBDAG is set by travis-ci according to the matrix in .travis.yml, so here we
    # force it to just use one. The default is to run two parallel jobs, but here
    # we set SUBDAGS to 1 so we only run a single job.
    #
    # See https://docs.travis-ci.com/user/speeding-up-the-build for more.
    env['SUBDAGS'] = '1'
    env['SUBDAG'] = '0'

    # When running on travis, these are set by the travis-ci environment, but
    # when running locally we have to simulate them.
    #
    # See https://docs.travis-ci.com/user/environment-variables for more.
    if platform.system() == 'Darwin':
        env['TRAVIS_OS_NAME'] = 'osx'
    else:
        env['TRAVIS_OS_NAME'] = 'linux'

    env['TRAVIS_BRANCH'] = 'false'
    env['TRAVIS_PULL_REQUEST'] = 'false'
    env['TRAVIS_REPO_SLUG'] = 'false'

    # Any additional arguments from the command line are added here.
    env['BIOCONDA_UTILS_BUILD_ARGS'] += ' ' + ' '.join(extra)
    env['BIOCONDA_UTILS_BUILD_ARGS'] = ' '.join(shlex.split(env['BIOCONDA_UTILS_BUILD_ARGS']))

    if (
        (env['TRAVIS_OS_NAME'] == 'linux') &
        (not args.disable_docker) &
        ('--docker' not in env['BIOCONDA_UTILS_BUILD_ARGS'])
    ):
        env['DOCKER_ARG'] = '--docker'

    # Override env with whatever's in the shell environment
    env.update(os.environ)
    sp.run(['scripts/travis-run.sh'], env=env, universal_newlines=True, check=True)
