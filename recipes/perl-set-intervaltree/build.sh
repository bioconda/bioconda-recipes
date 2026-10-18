#!/bin/bash

export LC_ALL="en_US.UTF-8"

if [[ -f Build.PL ]]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site CC="${CC}" NO_PACKLIST=1 NO_PERLLOCAL=1
    make
    make test -j"${CPU_COUNT}"
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
