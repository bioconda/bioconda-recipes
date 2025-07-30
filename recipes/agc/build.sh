#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's|-lpthread|-pthread|' refresh.mk
rm -rf *.bak

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	make PLATFORM=arm8 all
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	make PLATFORM=m1 all
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	make PLATFORM=avx2 all
	;;
esac

install -v -m 0755 bin/agc "${PREFIX}/bin"
install -v -m 0755 bin/py_agc*.so "${PREFIX}/lib"
cp -f bin/*.a "${PREFIX}/lib"
