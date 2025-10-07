#!/bin/bash
set -xe

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export LC_ALL="en_US.UTF-8"

mkdir -p "${PREFIX}/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* lib/

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

# fix other python and perl scripts
gawk -i inplace '/usr\/bin\//{ gsub(/python/, "env python");}1' script/*.py
gawk -i inplace '/usr\/bin\//{ gsub(/perl/, "env perl");}1' script/*

echo "===== CXX: ${CXX}"

autoreconf -if
./configure --prefix="$PREFIX" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--disable-option-checking \
	--enable-silent-rules \
	--disable-dependency-tracking

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"
install -v -m 0755 script/*py script/validate* "${PREFIX}/bin"

rm -f ${PREFIX}/bin/Makefile*
rm -f ${PREFIX}/bin/*.o
