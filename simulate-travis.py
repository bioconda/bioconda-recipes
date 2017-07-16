#!/usr/bin/env python

import os
import platform
import sys
import yaml
import subprocess as sp
import shlex
import shutil
import argparse

PY3 = False
if sys.version_info.major == 3:
    PY3 = True

if PY3:
    from urllib.request import urlretrieve
else:
    from urllib import urlretrieve

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


"""

ap = argparse.ArgumentParser(usage=usage)
ap.add_argument('--bootstrap', help='''Bootstrap a new conda installation to
                use only for bioconda-utils at the specified path, install
                bioconda-utils dependencies, and set channel order. Effectively
                runs --install-alternative-conda DIR --install-requirements --
                set-channel-order''')
ap.add_argument('--install-alternative-conda', help='''Install a separate conda
                environment to the specified location. This will download and
                install Miniconda, and then create a config file in
                ~/.config/bioconda/conf.yml that points to this installation so
                that subsequent runs of simulate-travis.py will use that
                installation with no additional configuration and without
                modifying any existing conda installations.''')
ap.add_argument('--force', action='store_true', help='''When installing conda
                (--install-alternative-conda or --bootstrap), overwrite the
                provided installation directory''')
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
ap.add_argument('--alternative-conda', help='''Path to alternative conda
                installation to override that installed and configured with
                --install-alternative-conda. If alternative conda executable is
                located at /opt/miniconda3/bin/conda, then pass /opt/miniconda3
                for this argument. Setting this argument will also set the
                CONDARC env var to "condarc" in this directory; in this example
                /opt/miniconda3/condarc.''')
args, extra = ap.parse_known_args()

HERE = os.path.abspath(os.path.dirname(__file__))


class TmpDownload(object):
    """
    Context manager to download to a temp file and clean up afterwards
    """
    def __init__(self, url):
        self.url = url

    def __enter__(self):
        filename, headers = urlretrieve(self.url)
        return filename

    def __exit__(self, exc_type, exc_value, traceback):
        urllib.request.urlcleanup()


def bin_for(name='conda'):
    """
    If CONDA_ROOT is set, we explicitly look for a bin there rather than defer
    to PATH. This should help keep the alternative conda installation truly
    isolated from the rest of the system.
    """
    if 'CONDA_ROOT' in os.environ:
        return os.path.join(os.environ['CONDA_ROOT'], 'bin', name)
    return name


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
        with TmpDownload(url) as f:
            cfg = yaml.load(open(f))
    else:
        cfg = yaml.load(open(os.path.join(HERE, fn)))
    return cfg

travis_config = _remote_or_local('.travis.yml', remote=args.config_from_github)
bioconda_utils_config = _remote_or_local('config.yml', remote=args.config_from_github)

# If the local config already exists then load it
local_config_path = os.path.expanduser(os.path.join('~/.config/bioconda/conf.yml'))
local_config = None
if os.path.exists(local_config_path):
    local_config = yaml.load(open(local_config_path))


# If this script is being called from an existing conda environment, the
# following changes to env vars will allow subsequent calls to conda etc use an
# alternative installation of conda.
#
# If --alternative-conda was provided on the command line, prefer that
if args.alternative_conda:
    os.environ['CONDARC'] = os.path.join(os.args.alternative_conda, 'condarc')
    os.environ['CONDA_ROOT'] = args.alternative_conda
    os.environ['PATH'] = os.path.join(args.alternative_conda, 'bin') + ':' + os.environ['PATH']

elif local_config:
    os.environ['CONDARC'] = local_config['CONDARC']
    os.environ['CONDA_ROOT'] = local_config['CONDA_ROOT']
    os.environ['PATH'] = os.path.join(local_config['CONDA_ROOT'], 'bin') + ':' + os.environ['PATH']

#print('Using conda at: {0}'.format(shutil.which('conda')))


# Load the env vars configured in .travis.yaml into os.environ
env = {}
for var in travis_config['env']['global']:
    if isinstance(var, dict) and list(var.keys()) == ['secure']:
        continue
    name, value = var.split('=', 1)
    env[name] = value


def _install_alternative_conda(install_path, force=False):
    """
    Download and install minconda to `install_path`.
    """
    miniconda_version = eval(env['MINICONDA_VER'])
    if sys.platform == 'linux':
        tag = 'Linux'
    elif sys.platform == 'darwin':
        tag = 'MacOSX'
    else:
        raise ValueError("platform {0} not supported".format(sys.platform))
    url = 'https://repo.continuum.io/miniconda/Miniconda3-{miniconda_version}-{tag}-x86_64.sh'.format(**locals())

    with TmpDownload(url) as f:
        cmds = ['bash', f, '-b', '-p', install_path]
        if force:
            cmds.append('-f')
        sp.check_call(cmds)

    # write the local config file
    d = {
        'CONDA_ROOT': install_path,
        'CONDARC': os.path.join(install_path, '.condarc')
    }
    config_dir = os.path.dirname(local_config_path)
    if not os.path.exists(config_dir):
        os.makedirs(config_dir)
    with open(local_config_path, 'w') as fout:
        yaml.dump(d, fout, default_flow_style=False)


def _install_requirements():
    """
    conda install and pip install bioconda dependencies
    """
    sp.run(
        [
            bin_for('conda'), 'install', '-y', '--file',
            'https://raw.githubusercontent.com/bioconda/bioconda-utils/'
            '{0}/bioconda_utils/bioconda_utils-requirements.txt'.format(env['BIOCONDA_UTILS_TAG'])
        ], check=True)

    sp.run(
        [
            bin_for('pip'), 'install',
            'git+https://github.com/bioconda/bioconda-utils.git@{0}'.format(env['BIOCONDA_UTILS_TAG'])
        ],
        check=True)


def _set_channel_order():
    channels = bioconda_utils_config['channels']
    print("""
          Warnings like "'conda-forge' already in 'channels' list, moving to the top"
          are expected if channels have been added before, and can be safely ignored.
          """)

    # The config (and .condarc) expect that higher-priority channels are listed
    # first, but when using `conda config --add` they should be added from
    # lowest to highest priority.
    for channel in channels[::-1]:
        sp.run([bin_for('conda'), 'config', '--add', 'channels', channel], check=True)
    print("\nconda config is now:\n")
    sp.run(['conda', 'config', '--get'])


if args.install_requirements:
    _install_requirements()
    sys.exit(0)

if args.install_alternative_conda:
    _install_alternative_conda(args.install_alternative_conda, force=args.force)
    sys.exit(0)

if args.set_channel_order:
    _set_channel_order()
    sys.exit(0)

if args.bootstrap:
    _install_alternative_conda(args.bootstrap, force=args.force)
    _install_requirements()
    _set_channel_order()
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
    try:
        sp.run(['scripts/travis-run.sh'], env=env, universal_newlines=True, check=True)
    except sp.CalledProcessError:
        sys.exit(1)
