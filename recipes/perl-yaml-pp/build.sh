#!/bin/bash

export LC_ALL="en_US.UTF-8"

sed -i.bak 's|v0.39.0|0.39.0|' lib/YAML/*.pm
rm -rf lib/YAML/*.bak
sed -i.bak 's|v0.39.0|0.39.0|' META.*
sed -i.bak 's|v0.39.0|0.39.0|' Makefile.PL
rm -rf *.bak

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site NO_PACKLIST=1 NO_PERLLOCAL=1
    make
    make test -j"${CPU_COUNT}"
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
