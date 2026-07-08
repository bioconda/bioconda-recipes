#!/bin/bash

export LC_ALL="en_US.UTF-8"

mkdir -p "${PREFIX}/bin"

if [[ `uname -s` == "Darwin" ]]; then
	sed -i.bak "s|#include <malloc.h>||g" gmove.cpp
fi

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	;;
esac

rm -f *.bak

make -j"${CPU_COUNT}"

install -v -m 0755 gmove "${PREFIX}/bin"
