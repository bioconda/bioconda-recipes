#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LC_ALL="en_US.UTF-8"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "(uname -s)" == "Darwin" ]]; then
	ln -sf ${CC} ${PREFIX}/bin/clang
	ln -sf ${CXX} ${PREFIX}/bin/clang++
else
	ln -sf ${CC} ${PREFIX}/bin/gcc
	ln -sf ${CXX} ${PREFIX}/bin/g++
fi

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site cc="${CXX}"
    make -j"${CPU_COUNT}"
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

if [[ "(uname -s)" == "Darwin" ]]; then
	rm -rf ${PREFIX}/bin/clang
	rm -rf ${PREFIX}/bin/clang++
else
	rm -rf ${PREFIX}/bin/gcc
	rm -rf ${PREFIX}/bin/g++
fi
