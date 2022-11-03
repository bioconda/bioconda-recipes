#!/bin/bash

set -o errexit -o pipefail

# Need to skip test 11-redirect-oo.t as $TERM is not set.
test_files='t/0*.t t/10-*.t t/12-*.t t/13-*.t t/14-*.t t/15-*.t t/16-*.t'

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    perl ./Build test TEST_FILES="$test_files"
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test TEST_FILES="$test_files"
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

# Add more build steps here, if they are necessary.

# See
# https://docs.conda.io/projects/conda-build
# for a list of environment variables that are set during the build process.
