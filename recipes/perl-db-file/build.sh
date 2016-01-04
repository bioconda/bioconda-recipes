#!/bin/bash

echo "INCLUDE = $PREFIX/include" > config.in
echo "LIB = $PREFIX/lib" >> config.in
echo "PREFIX = size_t" >> config.in
echo "HASH = u_int32_t" >> config.in

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
