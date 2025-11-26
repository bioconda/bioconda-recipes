#!/bin/bash

export CFLAGS="$CFLAGS -O3 -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -O3 -L$PREFIX/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|g' Makefile && rm -f *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|g' Makefile && rm -f *.bak
	;;
esac

if [[ "$(uname -s)" == "Darwin" ]]; then
	RPATH='@loader_path/../lib'
else
	ORIGIN='$ORIGIN'
	export ORIGIN
	RPATH='$${ORIGIN}/../lib'
fi

make CXX="$CXX"

install -v -m 0755 realign_cm merge_result read_extractor "${PREFIX}/bin"
