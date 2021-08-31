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

    # As the compiler bin is a symlink to another dir, the sysroot in the Makefile is wrong. Correcting it.
    # It would be better to make sure the Makefile is generated with the correct value, but I didn't find how the wrong value ended there.
    sed -i.bak 's|x86_64-conda_cos6-linux-gnu/sysroot|x86_64-conda-linux-gnu/sysroot|' Makefile

    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
