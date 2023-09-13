#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3" \
	INCLUDES="-I${PREFIX}/include" \
	LIBPATH="-L${PREFIX}/lib" -j4 build
${PYTHON} -m pip install . --use-pep517 --no-deps -vvv
