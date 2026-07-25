#!/bin/bash
set -eu -o pipefail

cd src

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-std=c++20|-std=c++20 -march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-std=c++20|-std=c++20 -march=armv8.4-a|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-std=c++20|-std=c++20 -march=x86-64-v3|' Makefile
	;;
esac

rm -rf *.bak

make
make install
