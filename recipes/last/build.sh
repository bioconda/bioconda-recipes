#!/bin/bash -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -pthread -I${PREFIX}/include"

# macOS specific flags to prevent compilation conflicts
if [[ `uname -s` == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET=11.3
    export MACOSX_SDK_VERSION=11.3
    export CFLAGS="${CFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

ARCH=$(uname -m)

case ${ARCH} in
    x86_64) ARCH_FLAGS="-msse4" ;;
    *) ARCH_FLAGS="" ;;
esac

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

make install CXXFLAGS="${CXXFLAGS} ${ARCH_FLAGS} ${LDFLAGS}" \
	prefix="${PREFIX}" -j"${CPU_COUNT}"
