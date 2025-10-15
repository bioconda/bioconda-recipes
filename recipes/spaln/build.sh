#!/bin/bash

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' perl/*.pl
rm -f perl/*.bak

install -v -m 0755 perl/*.pl "${PREFIX}/bin"

sed -i.bak 's|-O2|-O3|' src/Makefile.in

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-O3 -march=x86-64-v3|-O3 -march=armv8-a|' src/configure
	sed -i.bak 's|-O3|-O3 -march=armv8-a|' src/Makefile.in
	;;
    arm64)
	sed -i.bak 's|-O3 -march=x86-64-v3|-O3 -march=armv8.4-a|' src/configure
	sed -i.bak 's|-O3|-O3 -march=armv8.4-a|' src/Makefile.in
	;;
    x86_64)
	sed -i.bak 's|-O3|-O3 -march=x86-64-v3|' src/Makefile.in
	;;
esac
rm -f src/*.bak

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

cd src

CXX="${CXX}" ./configure --exec_prefix="${PREFIX}/bin" \
	--table_dir="${PREFIX}/share/spaln/table" --alndbs_dir="${PREFIX}/share/spaln/alndbs"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-O2|-O3|' Makefile
rm -f *.bak

make CFLAGS="${CXXFLAGS}" AR="${AR:-ar} rcs" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install

make clearall
