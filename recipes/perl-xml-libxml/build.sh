#!/bin/bash

if [ `uname -s` == "Darwin" ]; then
    # Force use of conda's libxml instead of the system one
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"

    # Give install_name_tool enough room to work its magic
    LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
else
    # Force use of conda's libxml instead of the system one
    export LD_LIBRARY_PATH="${PREFIX}/lib"
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
    perl Makefile.PL INSTALLDIRS=site LDFLAGS="$LDFLAGS"
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
