#!/bin/bash
set -ex

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++03"

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

case $(uname -m) in
    aarch64|arm64)
	sed -i.bak 's|-m64||g' configure.sh && rm -f *.bak;;
esac

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

CXXFLAGS="${CXXFLAGS}" make install

if [[ "$(uname -s)" == "Darwin" ]]; then
	install -v -m 0755 Darwin-*/bin/* "${PREFIX}/bin"
	cp -f Darwin-*/include/* ${PREFIX}/include/
	cp -f Darwin-*/lib/* ${PREFIX}/lib/
else
	install -v -m 0755 Linux-*/bin/* "${PREFIX}/bin"
	cp -f Linux-*/include/* ${PREFIX}/include/
	cp -f Linux-*/lib/* ${PREFIX}/lib/
fi
