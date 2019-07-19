#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL

if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    sed -i.bak 's/-fstack-protector-strong//g' Makefile
    sed -i.bak 's/-fstack-protector//g' Makefile
    sed -i.bak 's|-L/usr/local/lib|-L${PREFIX}/lib|g' Makefile
    sed -i.bak 's|LD_RUN_PATH = /usr/lib/../lib64|LD_RUN_PATH = ${PREFIX}/lib|g' Makefile
    sed -i.bak 's|LD_RUN_PATH = /usr/lib64|LD_RUN_PATH = ${PREFIX}/lib|g' Makefile
    sed -i.bak 's|-I/usr/local/include|-I${PREFIX}/include|g' Makefile
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
