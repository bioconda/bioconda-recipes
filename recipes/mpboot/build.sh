#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-deprecated-declarations -Wno-ignored-attributes -Wno-unused-result -Wno-deprecated -Wno-deprecated-non-prototype"

mkdir -p "${PREFIX}/bin"

# On x86 use -DIQTREE_FLAGS=avx, on arm use -DIQTREE_FLAGS=sse4
if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
    DCMAKE_ARGS+=(-DIQTREE_FLAGS=omp)
    EXE_NAME=mpboot
elif [[ "$(uname -m)" == "x86_64" ]]; then
    DCMAKE_ARGS+=(-DIQTREE_FLAGS=avx)
    EXE_NAME=mpboot-avx
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
else
	export CONFIG_ARGS=""
fi

sed -i.bak -e 's|VERSION 2.4.4|VERSION 3.5|' zlib-1.2.7/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.8|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak
rm -rf zlib-1.2.7/*.bak

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${DCMAKE_ARGS[@]}" \
	"${CONFIG_ARGS}"

# Detect if we are running on CircleCI's arm.medium VM
# If CPU_COUNT is 4, we are on CircleCI's arm.large VM
JOBS="${CPU_COUNT}"
if [[ "$(uname -m)" == "aarch64" ]] && [[ "${CPU_COUNT}" -lt 4 ]]; then
	JOBS=1  # CircleCI's arm.medium VM runs out of memory with higher values
fi

cd build
VERBOSE=1 make -j"${JOBS}"
cd ..

# install
install -v -m 0755 "${SRC_DIR}/build/${EXE_NAME}" "${PREFIX}/bin"

if [[ "$(uname -m)" == "x86_64" ]]; then
	ln -sf "${PREFIX}/bin/${EXE_NAME}" "${PREFIX}/bin/mpboot"
fi
