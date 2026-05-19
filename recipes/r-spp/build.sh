#!/bin/bash

export BOOST_ROOT="${PREFIX}"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export DISABLE_AUTOBREW=1
export LC_ALL="en_US.UTF-8"

if [[ "$(uname -s)" == "Darwin" ]]; then
    ${R} CMD INSTALL --build . "${R_ARGS}" --configure-args="CFLAGS=${CFLAGS} -ferror-limit=0 CXXFLAGS=${CXXFLAGS} -ferror-limit=0"
else
    ${R} CMD INSTALL --build . "${R_ARGS}"
fi
