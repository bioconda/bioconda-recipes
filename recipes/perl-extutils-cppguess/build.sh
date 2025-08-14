#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LC_ALL="en_US.UTF-8"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site CC="${CXX}"
    make CC="${CXX}"
    make test CC="${CXX}" -j"${CPU_COUNT}"
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
