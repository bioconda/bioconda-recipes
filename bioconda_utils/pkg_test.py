import subprocess as sp
import tempfile
import tarfile
import os
import shlex
import logging

from . import utils

from conda_build.metadata import MetaData

logger = logging.getLogger(__name__)


def get_tests(path):
    "Extract tests from a built package"
    tmp = tempfile.mkdtemp()
    t = tarfile.open(path)
    t.extractall(tmp)
    input_dir = os.path.join(tmp, 'info', 'recipe')

    tests = []
    recipe_meta = MetaData(input_dir)

    tests_commands = recipe_meta.get_value('test/commands')
    tests_imports = recipe_meta.get_value('test/imports')
    requirements = recipe_meta.get_value('requirements/run')

    if tests_imports or tests_commands:
        if tests_commands:
            tests.append(' && '.join(tests_commands))
        if tests_imports and 'python' in requirements:
            tests.append(
                ' && '.join('python -c "import %s"' % imp
                            for imp in tests_imports)
            )
        elif tests_imports and (
            'perl' in requirements or 'perl-threaded' in requirements
        ):
            tests.append(
                ' && '.join('''perl -e "use %s;"''' % imp
                            for imp in tests_imports)
            )

    tests = ' && '.join(tests)
    tests = tests.replace('$R ', 'Rscript ')
    return tests


def test_package(path, name_override=None, channels=["r", "defaults", "conda-forge"], mulled_args=""):
    """
    Tests a built package in a minimal docker container.

    Parameters
    ----------
    path : str
        Path to a .tar.bz2 package built by conda-build

    name_override : str
        Passed as the --name-override argument to mulled-build

    channels : None | str | list
        The local channel of the provided package will be added automatically;
        `channels` are channels to use in addition to the local channel.

    mulled_args : str
        Mechanism for passing arguments to the mulled-build command. They will
        be split with shlex.split and passed to the mulled-build command. E.g.,
        mulled_args="--dry-run --involucro-path /opt/involucro"

    """

    assert path.endswith('.tar.bz2'), "Unrecognized path {0}".format(path)
    # assert os.path.exists(path), '{0} does not exist'.format(path)

    conda_bld_dir = os.path.abspath(os.path.dirname(os.path.dirname(path)))

    sp.check_call(['conda', 'index', os.path.dirname(path)])

    pkg = os.path.basename(path).replace('.tar.bz2', '')
    toks = pkg.split('-')
    build_string = toks[-1]
    version = toks[-2]
    name = '-'.join(toks[:-2])

    spec = '%s=%s--%s' % (name, version, build_string)

    extra_channels = ['file:/{0}'.format(conda_bld_dir)]
    if channels is None:
        channels = []
    if isinstance(channels, str):
        channels = [channels]
    extra_channels.extend(channels)
    channel_args = ['--extra-channels',','.join(extra_channels)]

    tests = get_tests(path)
    logger.debug('Tests to run: %s', tests)
    # Path to a file where we store the push commands to push all containers to
    # a Docker registry
    push_containers = os.environ.get('CONTAINER_PUSH_COMMANDS_PATH', False)

    cmd = [
        'mulled-build',
        'build-and-test',
        spec,
        '-n', 'biocontainers',
        '--test', tests
    ]
    if name_override:
        cmd += ['--name-override', name_override]
    cmd += channel_args
    cmd += shlex.split(mulled_args)
    if push_containers:
        try:
            with open(push_containers, 'a+') as handle:
                handle.write('mulled-build push %s -n biocontainers\n' % (spec))
            logger.debug('Container push commands have been written to "%s"', push_containers)
        except:
            logger.error('Could not write container push commands to "%s"', push_containers)
    else:
        logger.debug('No container push commands are generated')
    logger.debug('mulled-build command: %s' % cmd)
    return utils.run(cmd)
