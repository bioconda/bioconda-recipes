#!/bin/bash
set -e -o pipefail -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" ]]; then
	export CAIRO_OPT="cairo=no"
	export LIBS="LIBS=-lc"
else
	export CAIRO_OPT="cairo=yes"
	export LIBS=""
fi

make "${CAIRO_OPT}" errorcheck=no "${LIBS}" -j"${CPU_COUNT}"
make "${CAIRO_OPT}" prefix="${PREFIX}" install

cd gtpython

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
