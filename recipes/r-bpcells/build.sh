#!/bin/bash

export DISABLE_AUTOBREW=1
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

pushd r/
${R} CMD INSTALL --build --install-tests . ${R_ARGS}
popd
