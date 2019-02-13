#!/bin/bash

# Accept defaults so we don't get prompted about installing scripts or running
# test that require network connectivity
export PERL_MM_USE_DEFAULT=1

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    # Don't run tests as we don't want to install all the binaries (including
    # those we can't include in BioBuilds) just to run the build system.
    #./Build test

    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    # Don't run tests as we don't want to install all the binaries (including
    # those we can't include in BioBuilds) just to run the build system.
    #make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
