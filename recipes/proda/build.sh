#!/bin/bash
set -eu -o pipefail
#
# CONDA build script variables
#
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	;;
esac

make CXX="${CXX}" -j"${CPU_COUNT}"

# install proda in the target bin directory

install -v -m 0755 proda "$PREFIX/bin"
