#!/usr/bin/env python

import os
import platform
import sys
try:
    import yaml
except ImportError:
    print('Please install pyyaml (try: pip install pyyaml)')
    sys.exit(1)
import subprocess as sp
import shlex
import argparse

if sys.version_info.major == 3:
    PY3 = True
    from urllib.request import urlretrieve, urlcleanup

else:
    PY3 = True
    from urllib import urlretrieve, urlcleanup

usage = """
This is the script used on travis-ci to set up the environment for testing. It
is also used on a local machine to test recipes before submitting a pull
request. Both Python 2 and Python 3 are supported, and the only dependency is
PyYAML (pip install pyyaml).

Recommended usage is to run the following command in the top level of
the bioconda-recipes repo before building::

    ./simulate-travis.py --bootstrap /tmp/anaconda --overwrite

This will:
    - build a new installation of conda in /tmp/anaconda. This remains separate
      from any system Python or conda installations you currently have.
    - set the proper channel order in that installation
    - install bioconda-utils dependencies in that installation
    - create a file ~/.config/bioconda/conf.yml that stores the location of
      this new installation

Subsequent calls of simulate-travis.py will then use that stored
configuration::

    ./simulate-travis.py --git-range HEAD

Additional arguments can be used for more fine-grained control over the
isolated conda installation.
"""

ap = argparse.ArgumentParser(usage=usage)
ap.add_argument('--bootstrap', help='''Bootstrap a new conda installation at
                the provided path. Will be used only for bioconda-utils.
                Installs conda, sets channel order, and installs bioconda-utils
                dependencies to the new conda installation. Effectively runs
                --install-alternative-conda DIR --set-channel-order
                --install-requirements''')
ap.add_argument('--install-alternative-conda', help='''Install a separate conda
                environment to the specified location and then exit. This will
                download and install Miniconda, and then create a config file
                in ~/.config/bioconda/conf.yml that points to this installation
                so that subsequent runs of simulate-travis.py will use that
                installation with no additional configuration and without
                modifying any existing conda installations.''')
ap.add_argument('--overwrite', action='store_true', help='''When installing conda
                via --install-alternative-conda or --bootstrap, overwrite an
                existing installation. NOTE: the most complete way would be to
                manually delete the directory first, but for safety we do not
                do that automatically. This argument just passes "-f" to the
                miniconda installer. ''')
ap.add_argument('--skip-linting', action='store_true', help='''Disable the
                recipe linting that is performed by default.''')
ap.add_argument('--git-range', nargs='+', help='''Override the default
                --git-range arguments to `bioconda-utils lint` and
                `bioconda-utils build`.''')
ap.add_argument('--install-requirements', action='store_true', help='''Install
                the version of bioconda-utils configured in .travis.yml and its
                dependencies, and then exit. If ~/.config/bioconda/conf.yml
                exists, then bioconda-utils and dependencies will be installed
                in the root of the conda environment specified in that
                file, unless overridden by --alternative-conda.''')
ap.add_argument('--set-channel-order', action='store_true', help='''Set the
                correct channel priorities, as specified in ./config.yml, in
                the conda environment specified in
                ~/.config/bioconda/config.yml and then exit.''')
ap.add_argument('--config-from-github', action='store_true', help='''Download
                and use the config.yml and .travis.yml files from the master
                branch of the github repo. Default is to use the files
                currently on disk.''')
ap.add_argument('--disable-docker', action='store_true', help='''By default, if
                the OS is linux then we use Docker for building and independent
                testing using mulled-build. Use this argument to disable this
                behavior''')
ap.add_argument('--disable-mulled', action='store_true', help='''By default, if
                the OS is linux and --disable-docker has not been specified,
                then we run independent mulled-build tests on
                a successfully-built recipe. Use this argument to disable this
                behavior''')
ap.add_argument('--alternative-conda', help='''Path to alternative conda
                installation to override that installed and configured with
                --install-alternative-conda. If the conda executable you want
                to use is located at /opt/miniconda3/bin/conda, then pass
                /opt/miniconda3 for this argument. Setting this argument will
                also set the CONDARC env var to "condarc" in this directory (so
                in this example CONDARC=/opt/miniconda3/condarc).''')
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
        urlcleanup()


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
local_config_path = os.path.expanduser('~/.config/bioconda/conf.yml')


def _update_env():

    # If --alternative-conda was provided on the command line, prefer that
    if args.alternative_conda:
        os.environ['CONDARC'] = os.path.join(os.args.alternative_conda, 'condarc')
        os.environ['CONDA_ROOT'] = args.alternative_conda
        return

    # If the local config already exists then load it
    local_config = {}
    if os.path.exists(local_config_path):
        local_config = yaml.load(open(local_config_path))
        print('Using config file {0}, which has the following contents:'.format(local_config_path))
        print(local_config)
    os.environ.update(local_config)

# Load the env vars configured in .travis.yaml into os.environ
env = {}
for var in travis_config['env']['global']:
    if isinstance(var, dict) and list(var.keys()) == ['secure']:
        continue
    name, value = var.split('=', 1)
    env[name] = value

# Linting and building both pay attention to this env var.
if args.git_range:
    os.environ['RANGE_ARG'] = '--git-range ' + ' '.join(args.git_range)


def _install_alternative_conda(install_path, overwrite=False):
    """
    Download and install minconda to `install_path`.
    """
    # strips quotes however they were used in yaml
    miniconda_version = shlex.split(env['MINICONDA_VER'])[0]
    if 'linux' in sys.platform:
        tag = 'Linux'
    elif sys.platform == 'darwin':
        tag = 'MacOSX'
    else:
        raise ValueError("platform {0} not supported".format(sys.platform))
    url = 'https://repo.continuum.io/miniconda/Miniconda3-{miniconda_version}-{tag}-x86_64.sh'.format(**locals())

    with TmpDownload(url) as f:
        cmds = ['bash', f, '-b', '-p', install_path]
        if overwrite:
            cmds.append('-f')
        sp.check_call(cmds)

    # write the local config file
    d = {
        'CONDA_ROOT': install_path,
        'CONDARC': os.path.join(install_path, 'condarc')
    }
    config_dir = os.path.dirname(local_config_path)
    if not os.path.exists(config_dir):
        os.makedirs(config_dir)
    with open(local_config_path, 'w') as fout:
        yaml.dump(d, fout, default_flow_style=False)

    os.environ.update(d)


def _install_requirements():
    """
    conda install and pip install bioconda dependencies
    """
    _update_env()
    sp.check_call(
        [
            bin_for('conda'), 'install', '-n', 'root', '-y', '--file',
            'https://raw.githubusercontent.com/bioconda/bioconda-utils/'
            '{0}/bioconda_utils/bioconda_utils-requirements.txt'.format(env['BIOCONDA_UTILS_TAG'])
        ])

    sp.check_call(
        [
            bin_for('pip'), 'install',
            'git+https://github.com/bioconda/bioconda-utils.git@{0}'.format(env['BIOCONDA_UTILS_TAG'])
        ])


def _set_channel_order():
    _update_env()
    channels = bioconda_utils_config['channels']
    print("""
          Warnings like "'conda-forge' already in 'channels' list, moving to the top"
          are expected if channels have been added before, and can be safely ignored.
          """)

    # The config (and .condarc) expect that higher-priority channels are listed
    # first, but when using `conda config --add` they should be added from
    # lowest to highest priority.
    for channel in channels[::-1]:
        sp.check_call([bin_for('conda'), 'config', '--add', 'channels', channel])
    print("\nconda config is now:\n")
    sp.check_call([bin_for('conda'), 'config', '--get'])


if args.install_requirements:
    _install_requirements()
    sys.exit(0)

if args.install_alternative_conda:
    _install_alternative_conda(args.install_alternative_conda, overwrite=args.overwrite)
    sys.exit(0)

if args.set_channel_order:
    _set_channel_order()
    sys.exit(0)

if args.bootstrap:
    _install_alternative_conda(args.bootstrap, overwrite=args.overwrite)
    _set_channel_order()
    _install_requirements()
    sys.exit(0)

if args.skip_linting:
    os.environ['SKIP_LINTING'] = 'true'

# Only run if we're not on travis.
if os.environ.get('TRAVIS', None) != 'true':

    _update_env()

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
        if not args.disable_mulled:
            env['DOCKER_ARG'] += ' --mulled-test'

    # Override env with whatever's in the shell environment
    env.update(os.environ)

    # Only at the very end do we want to modify the path:
    if 'CONDA_ROOT' in os.environ:
        env['PATH'] = os.path.join(
            os.environ['CONDA_ROOT'], 'bin') + ':' + env['PATH']

    try:
        sp.check_call(['scripts/travis-run.sh'], env=env, universal_newlines=True)
    except sp.CalledProcessError:
        sys.exit(1)
