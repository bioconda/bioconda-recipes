#!/bin/bash

export LC_ALL="en_US.UTF-8"

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    #perl ./Build test
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    perl Makefile.PL INSTALLDIRS=site NO_PACKLIST=1 NO_PERLLOCAL=1
    make
    #make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
