#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

mkdir -p "${PREFIX}/bin"

if [[ `uname -s` == "Darwin" ]]; then
	sed -i.bak 's|-static||' source/Makefile
fi

sed -i.bak 's|BayeScan 2.0|BayeScan 2.1|' source/start.cpp
sed -i.bak 's|strcpy (long_opt_prefix,  _prefix)|strncpy (long_opt_prefix,  _prefix, MAX_LONG_PREFIX_LENGTH)|' source/anyoption.cpp
sed -i.bak 's|strcpy( long_opt_prefix , "--" )|strncpy( long_opt_prefix , "--", MAX_LONG_PREFIX_LENGTH )|' source/anyoption.cpp
rm -f source/*.bak

cd source

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 bayescan_2.1 "${PREFIX}/bin"
