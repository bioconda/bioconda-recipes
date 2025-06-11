#!/bin/bash

set -e -o pipefail -x

#export LIBRARY_PATH="${PREFIX}/lib"
#export INCLUDE_PATH="${PREFIX}/include"
#export CFLAGS="${CFLAGS} -O3 -fcommon"
#export CXXFLAGS="${CFLAGS} -O3 -fcommon -I${PREFIX}/include -D_LIBCPP_DISABLE_AVAILABILITY"

case $(uname) in
	Linux)
		THREADS="-rj${CPU_COUNT}"
		;;
	Darwin)
		THREADS=""
		;;
esac

mkdir -p ${PREFIX}/bin ${PREFIX}/share
cd assembler
./spades_compile.sh "${THREADS}"
