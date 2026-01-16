#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p ${PREFIX}/bin

rm -rf cmake-build-release

echo "Step 1"
echo ${PWD}
echo "...SRCDIR= $SRC_DIR"
export VERBOSE=1

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

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

cmake -S . -B cmake-build-release -G Ninja \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

echo "Step 2"
echo ${PWD}
echo "ninja -C cmake-build-release -j ${CPU_COUNT} install"

ninja -C cmake-build-release -j "${CPU_COUNT}" install

install -v -m 0755 cmake-build-release/protal "${PREFIX}/bin/protal_plain"
install -v -m 0755 cmake-build-release/protal_avx2 "${PREFIX}/bin"
cp -fv protal_launcher "${PREFIX}/bin/protal"
