#!/bin/bash
set -ex

export LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p $PREFIX/bin

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

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

sed -i.bak "s/-march=x86-64-v3/-march=${MARCH}/g" src/common/wflign/CMakeLists.txt

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Generic \
	-DEXTRA_FLAGS="${EXTRA_FLAGS}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"

# Libraries aren't getting installed
mkdir -p $PREFIX/lib

ls $SRC_DIR/build/lib/* -lh

cp -f $SRC_DIR/build/lib/libwfa2* $PREFIX/lib
cp -f $SRC_DIR/build/lib/libwflign* $PREFIX/lib

install -v -m 0755 build/bin/* $PREFIX/bin
cp -f scripts/split_approx_mappings_in_chunks.py $PREFIX/bin
