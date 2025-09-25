#!/bin/bash
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|g++|$(CXX)|' Release/makefile
sed -i.bak 's|-lpthread|-pthread|' Release/objects.mk
sed -i.bak 's|g++|$(CXX)|' Release/subdir.mk
sed -i.bak 's|-O3|-O3 -std=c++03 -march=x86-64-v3|' Release/subdir.mk

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Release/subdir.mk
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Release/subdir.mk
	;;
esac
rm -f Release/*.bak

make clean
make CXX="${CXX}"

install -v -m 0755 Release/GapCloser "$PREFIX/bin"
