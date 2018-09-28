#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL

HOME=/tmp cpanm Test2::Bundle::Extended
HOME=/tmp cpanm --installdeps .

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

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
