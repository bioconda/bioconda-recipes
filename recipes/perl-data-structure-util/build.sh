#!/bin/bash

set -o errexit -o pipefail
BINARY_HOME=$PREFIX/lib/perl5/5.32/site_perl
# If it has Build.PL use that, otherwise use Makefile.PL
if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
    cp -r $BUILD_PREFIX/lib/perl5/5.32/site_perl/* $BINARY_HOME/
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi