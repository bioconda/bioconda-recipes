#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -I. -I${PREFIX}/include -O3 -std=c++14"

install -d "${PREFIX}/bin"

${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir --use-pep517 -vvv

cd probeit/setcover

make CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 setcover "${PREFIX}/bin"
