#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p build

ARCH_BUILD=""

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

case $(uname -m) in
	x86_64) ARCH_BUILD="-DHAVE_SSE4_1=1" ;;
	arm64|aarch64) ARCH_BUILD="-DHAVE_ARM8=1" ;;
esac

if [[ `uname -s` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

if [[ -z "${ARCH_BUILD}" ]]; then
	echo "Invalid architecture"
	exit 1
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DHAVE_TESTS=0 -DHAVE_MPI=1 \
	-DVERSION_OVERRIDE="${PKG_VERSION}" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${ARCH_BUILD}" \
	"${CONFIG_ARGS}"

cd build
make -j"${CPU_COUNT}" "${VERBOSE_CM}"
make install
