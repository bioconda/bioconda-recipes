#!/bin/bash

set -o errexit -o pipefail
# If it has Build.PL use that, otherwise use Makefile.PL
if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL # INSTALLDIRS=site
    make
    make test
    make install
    mkdir -p $PREFIX/lib/perl5/site_perl/5.28.1/
    cp -r $BUILD_PREFIX/lib/site_perl/5.26.2/* $PREFIX/lib/perl5/site_perl/5.28.1/
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

# Add more build steps here, if they are necessary.
# See
# https://docs.conda.io/projects/conda-build
# for a list of environment variables that are set during the build process.
