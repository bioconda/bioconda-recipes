#!/bin/bash
set -xe

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

# Remove configure.ac C(XX)?FLAGS override
sed -i.bak 's/ *CX\?X\?FLAGS/#\0/p' configure.ac
# Remove MACOS_DEPLOYMENT_TARGET override
sed -i.bak 's/MACOSX_DEPLOYMENT_TARGET=/#\0/' configure.ac
sed -i.bak 's/export MACOSX_DEPLOYMENT_TARGET=/#\0/' src/Makefile.am

rm -f *.bak src/*.bak

autoreconf -if
./configure --prefix="${PREFIX}" \
  --disable-option-checking \
  --enable-silent-rules \
  --disable-dependency-tracking \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}"

make ARFLAGS="rcs" -j"${CPU_COUNT}"
make install
