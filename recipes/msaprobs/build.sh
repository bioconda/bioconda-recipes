#!/bin/bash

mkdir -p "$PREFIX/bin"

cd MSAProbs

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile && rm -f *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile && rm -f *.bak
	;;
esac

make all

install -v -m 0755 msaprobs "$PREFIX/bin"
