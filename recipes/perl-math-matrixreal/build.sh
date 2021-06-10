#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL
# if [ -f Build.PL ]; then
#    perl Build.PL
#    ./Build
#    ./Build test
#    # Make sure this goes in site
#    ./Build install --installdirs site
# If it has Makefile.PL use that, otherwise use Build.PL
if [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
elif [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
