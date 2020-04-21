#!/usr/bin/env python

import os
import sys
import subprocess as sp
import argparse

if sys.version_info.major == 3:
    PY3 = True
    from urllib.request import urlretrieve

else:
    PY3 = True
    from urllib import urlretrieve

usage = """
The easy way to test recipes is by using `circleci build`. However this does
not allow local testing recipes using mulled-build (due to the technicalities
of running docker within docker and the CircleCI client).

This script makes it easy to do mulled-build tests. It works by using the same
code used in the .circleci/setup.sh script to build an isolated Miniconda
environment and a custom `activate` script.

Set up the environment like this:

    ./bootstrap.py /tmp/miniconda

It creates an activate script at ~/.config/bioconda/activate. So you can then use:

    source ~/.config/bioconda/activate

and then use that isolated root environment independent of any other conda
installations you might have.
"""

ap = argparse.ArgumentParser(usage)
ap.add_argument('bootstrap', help='''Location to which a new Miniconda
                installation plus bioconda-utils should be installed. This will
                be separate from any existing conda installations.''')
ap.add_argument('--no-docker', action='store_true', help='''By default we
                expect Docker to be present. Use this arg to disable that
                behavior. This will reduce functionality, but is useful if
                you're unable to install docker.''')
args = ap.parse_args()

# This is the "common" step in the CircleCI config which gets the versions of
# Miniconda and bioconda-utils that we're using.
urlretrieve(
    'https://raw.githubusercontent.com/bioconda/bioconda-common/master/common.sh',
    filename='.circleci/common.sh')

# TODO: this mimics the override in the "common" job in .circleci/config.yaml
with open('.circleci/common.sh', 'w') as fout:
    fout.write("MINICONDA_VER=4.6.14\nBIOCONDA_UTILS_TAG=master\n")

local_config_path = os.path.expanduser('~/.config/bioconda/activate')

def _write_custom_activate(install_path):
    """
    Once the isolated Miniconda version has been installed, copy its activate
    script over to a custom location, and then hard-code the paths and PS1. We
    don't need a matching `deactivate` because the activate script properly
    keeps track of the new location.
    """
    config_dir = os.path.dirname(local_config_path)
    if not os.path.exists(config_dir):
        os.makedirs(config_dir)

    activate = os.path.join(install_path, 'miniconda/bin/activate')
    lines = [i.rstrip() for i in open(activate)]


    # The following is code from cb2; disabling but keeping it around for now:
    if 0:
        # Exact matches to lines we want to replace in the activate script, leading
        # space included.
        substitutions = [
            (
                '_CONDA_DIR=$(dirname "$_SCRIPT_LOCATION")',
                '_CONDA_DIR="{0}/miniconda/bin"'.format(install_path)
            ),
            (
                '                export PS1="(${CONDA_DEFAULT_ENV}) $PS1"',
                '                export PS1="(BIOCONDA-UTILS) $PS1"',
            )
        ]

        for orig, sub in substitutions:
            # Be very picky so that we'll know if/when the activate script changes.
            try:
                pos = lines.index(orig)
            except ValueError:
                raise ValueError(
                    "Expecting '{0}' to be in {1} but couldn't find it"
                    .format(orig, activate)
                )
            lines[pos] = sub

    with open(local_config_path, 'w') as fout:
        for line in lines:
            fout.write(line + '\n')


use_docker = "true"
if args.no_docker:
    use_docker = "false"

env = {
    'WORKSPACE': args.bootstrap, 
    'BOOTSTRAP': "true", 
    'USE_DOCKER': use_docker, 
    'PATH': os.environ.get('PATH', ""),
    'HTTPS_PROXY': os.environ.get('HTTPS_PROXY', ""),
    'https_proxy': os.environ.get('https_proxy', "")
}

sp.check_call(['.circleci/setup.sh'], env=env)
_write_custom_activate(args.bootstrap)

print("""

An isolated version of bioconda-utils has been installed to {1}. This is
separate from any other conda installations you might have.

To use it, source this custom activate script:

    source ~/.config/bioconda/activate

When done:

    source deactivate

""")
