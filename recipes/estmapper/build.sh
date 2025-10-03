#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

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

case $(uname -m) in
    aarch64|arm64)
	sed -i.bak 's|-m64||g' configure.sh && rm -f *.bak;;
esac

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

CXXFLAGS="${CXXFLAGS} -std=c++03" make install

if [[ "$(uname -s)" == "Darwin" ]]; then
	install -v -m 0755 Darwin-amd64/bin/* "${PREFIX}/bin"
	cp Darwin-amd64/include/* ${PREFIX}/include/
	cp Darwin-amd64/lib/* ${PREFIX}/lib/
else
	install -v -m 0755 Linux-amd64/bin/* "${PREFIX}/bin"
	cp Linux-amd64/include/* ${PREFIX}/include/
	cp Linux-amd64/lib/* ${PREFIX}/lib/
fi
