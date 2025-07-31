#!/bin/bash
set -e -o pipefail -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

#CAIRO_OPT=
#LIBS=
#if [[ "$(uname -s)" == "Darwin" ]]; then
	#CAIRO_OPT="cairo=no"
	#LIBS="LIBS=-lc"
#fi

#"${CAIRO_OPT}"
#"${LIBS}"
make CC="${CC}" CXX="${CXX}" errorcheck=no -j"${CPU_COUNT}"
make prefix="${PREFIX}" install

cd gtpython

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
