#!/bin/bash

# Make sure pipes to tee don't hide configuration or test failures
set -o pipefail

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL 2>&1 | tee configure.log
    ./Build
    ./Build test 2>&1 | tee tests.log
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site 2>&1 | tee configure.log
    make
    make test 2>&1 | tee tests.log
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
