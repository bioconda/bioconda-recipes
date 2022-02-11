#!/bin/bash

if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    #perl ./Build test
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    perl Makefile.PL INSTALLDIRS=site
    make
    # Tries to read /etc/fstab, which won't exist in docker
    #make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

