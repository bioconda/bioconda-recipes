#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"
export MACHTYPE=$(uname -m)
export INCLUDE_PATH="${PREFIX}/include"
# htslib's Makefile assigns CPPFLAGS/CFLAGS outright, discarding the environment,
# so ${PREFIX}/include only reaches its compiles via gcc's own CPATH.
export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export COPT="${COPT} ${CFLAGS}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export BINDIR=$(pwd)/bin
export L="${LDFLAGS}"
mkdir -p "${BINDIR}"
# CFLAGS must stay out of the make argument list: a command-line variable
# overrides the makefile, so common.mk's "CFLAGS += -std=c11" would be dropped
# and kent's unprototyped declarations fail under the compiler's default -std.
(cd kent/src && make libs PTHREADLIB=1 CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}")
(cd kent/src/utils/stringify && make CC="${CC}" -j"${CPU_COUNT}")
(cd kent/src/utils/pslMap && make CC="${CC}" -j"${CPU_COUNT}")
cp bin/pslMap "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/pslMap"
