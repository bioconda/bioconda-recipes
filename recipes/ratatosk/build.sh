#!/bin/bash -ex

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64"

sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' CMakeLists.txt
sed -i.bak 's|-std=c11|-O3 -std=c11|' CMakeLists.txt
sed -i.bak 's|-std=c++11|-O3 -std=c++14|' CMakeLists.txt
sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' Bifrost/CMakeLists.txt
sed -i.bak 's|-std=c11|-O3 -std=c11|' Bifrost/CMakeLists.txt
sed -i.bak 's|-std=c++11|-O3 -std=c++14|' Bifrost/CMakeLists.txt
rm -rf *.bak
rm -rf Bifrost/*.bak

OS=$(uname -s)
ARCH=$(uname -m)

case ${ARCH} in
	aarch64|arm64) sed -i.bak 's|-mno-avx2||' Bifrost/CMakeLists.txt && rm -rf Bifrost/*.bak ;;
esac

case ${ARCH} in
    x86_64) ARCH_FLAGS="-DCOMPILATION_ARCH=OFF" ;;
    aarch64) ARCH_FLAGS="-DCOMPILATION_ARCH=OFF" ;;
    *) ARCH_FLAGS="-DCOMPILATION_ARCH=ON" ;;
esac

if [[ ${OS} == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CXXFLAGS="${CXXFLAGS} -std=libc++"
else
	export CONFIG_ARGS=""
fi

if [[ ${OS} == "Linux" && ${ARCH} == "x86_64" ]]; then
	ARCH_FLAGS="${ARCH_FLAGS} -DENABLE_AVX2=ON"
else
 	ARCH_FLAGS="${ARCH_FLAGS} -DENABLE_AVX2=OFF"
fi

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}" "${ARCH_FLAGS}"

cmake --build build/ --clean-first --target install -j "${CPU_COUNT}"
