#!/bin/bash

if [ `uname -s` == "Darwin" ]; then
    # Needed because, despite the message, "LIBS=" alone does not seem to
    # enough information for the build system to find libxslt.
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site DEBUG=1
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
