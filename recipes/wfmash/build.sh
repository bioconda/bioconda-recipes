#!/bin/bash
set -ex

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

case $(uname -m) in
    x86_64)
        EXTRA_FLAGS="-march=sandybridge -Ofast"
        MARCH="sandybridge"
        ;;
    *)
        EXTRA_FLAGS="-march=native -Ofast"
        MARCH="native"
        ;;
esac

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
        export CONFIG_ARGS=""
fi

#sed -i.bak "s/-march=x86-64-v3/-march=${MARCH}/g" src/common/wflign/deps/WFA2-lib/Makefile
#rm -rf src/common/wflign/deps/WFA2-lib/*.bak

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Generic -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -DWFA_PNG_TSV_TIMING=ON \
	-DEXTRA_FLAGS="${EXTRA_FLAGS}" "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}"

# Libraries aren't getting installed
# ls ${SRC_DIR}/build/lib/* -lh
# cp -rf ${SRC_DIR}/build/lib/libwfa2* ${PREFIX}/lib

# chmod 0755 build/bin/*
# cp -rf build/bin/* ${PREFIX}/bin
# cp -rf scripts/split_approx_mappings_in_chunks.py ${PREFIX}/bin
