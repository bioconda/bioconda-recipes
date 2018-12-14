#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL
if [ "$(uname)" == "Darwin" ]; then
    HOME=/tmp cpanm --installdeps .
    HOME=/tmp cpanm Devel::StackTrace
else
    cpanm --installdeps .
    cpanm Devel::StackTrace
fi


if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
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
