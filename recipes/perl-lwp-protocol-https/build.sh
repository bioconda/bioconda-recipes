#!/bin/bash

export LC_ALL="en_US.UTF-8"
export OPENSSL_PREFIX="${PREFIX}"

# If it has Build.PL use that, otherwise use Makefile.PL
if [[ -f Build.PL ]]; then
    perl Build.PL
    ./Build
    ./Build test
    ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    perl Makefile.PL INSTALLDIRS=site NO_PACKLIST=1 NO_PERLLOCAL=1
    make
    #make test  # Disabled as it doesn't work on circleci but works locally (network problem probably)
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
