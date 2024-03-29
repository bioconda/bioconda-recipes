#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export LD_RUN_PATH="${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

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
    #Hack to get this built on OSX
    sed -i.bak 's|cc -c|${CC} -c -I${PREFIX}/include -L${PREFIX}/lib|g' Makefile
    sed -i.bak "s#^LDDLFLAGS = #LDDLFLAGS = ${LDFLAGS} -L$PREFIX/lib -lssl -lcrypto #g" Makefile
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
