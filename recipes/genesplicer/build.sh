#!/bin/bash

export target="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
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

mkdir -p "$target"
mkdir -p "$PREFIX/bin"

#delete precompiled executables
rm -rf bin/

#compile new executable
cd sources/

# fix error: "C++ requires a type specifier for all declarations" on macOS
sed -i.bak 's|main  (|int main  (|' genesplicer.cpp
rm -f *.bak

make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

#move everything to target directory
install -v -m 0755 genesplicer "$target"
cd ../

rm -rf sources
cp -rf * $target

chmod 0755 $target/*
ln -sf $target/genesplicer $PREFIX/bin
