#!/usr/bin/env python

import os
import platform
import sys
import yaml
import subprocess as sp
import argparse

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
args, extra = ap.parse_known_args()

# Read in the current .travis.yml to ensure we're getting the right vars.
# Mostly we care about the bioconda-utils git tag.
travis_config = yaml.load(open('.travis.yml'))
env = {}
for var in travis_config['env']['global']:
    if isinstance(var, dict) and list(var.keys()) == ['secure']:
        continue
    name, value = var.split('=', 1)
    env[name] = value

# SUBDAG is set by travis-ci according to the matrix in .travis.yml, so here we
# force it to just use one. The default is to run two parallel jobs, but here
# we set SUBDAGS to 1 so we only run a single job.
#
# See https://docs.travis-ci.com/user/speeding-up-the-build for more.
env['SUBDAGS'] = '1'
env['SUBDAG'] = '0'

# These are set by the travis-ci environment; here we only set the variables
# used by bioconda-utils.
#
# See https://docs.travis-ci.com/user/environment-variables for more.
if platform.system() == 'Darwin':
    env['TRAVIS_OS_NAME'] = 'osx'
else:
    env['TRAVIS_OS_NAME'] = 'linux'

env['TRAVIS_BRANCH'] = 'false'
env['TRAVIS_PULL_REQUEST'] = 'false'

# Any additional arguments from the command line are added here.
env['BIOCONDA_UTILS_ARGS'] += ' ' + ' '.join(extra)

sp.check_call(['scripts/travis-run.sh'], env=env)
