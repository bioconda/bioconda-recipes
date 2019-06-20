#!/bin/bash

export PATH=/opt/rh/devtoolset-2/root/usr/bin/:$PATH
HOME=/tmp cpanm --installdeps .

sed -i.bak 's|#!/usr/bin/env perl|#!perl|g' script/hpcrunner.pl
rm -rf script/hpcrunner.pl.bak

if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    #perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    #make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
