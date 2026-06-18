#!/bin/bash
set -ex

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="$CXXFLAGS -O3"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

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

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DHASH_MAP=USE_TSL_ROBIN_MAP \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	--install-prefix="$PREFIX" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
	
cmake --build build --target all --target diff-dna --target diff-aa --target dump-dna --target dump-aa -j "${CPU_COUNT}"
cmake --install build

install -v -m 0755 build/ipk/ipk-aa \
	build/ipk/ipk-aa-pos \
	build/ipk/ipk-dna \
	build/tools/ipkdiff-dna \
	build/tools/ipkdiff-aa \
	build/tools/ipkdump-dna \
	build/tools/ipkdump-aa "$PREFIX/bin"

cp -f build/i2l/libi2l_aa.a $PREFIX/lib
cp -f build/i2l/libi2l_aa_pos.a $PREFIX/lib
cp -f build/i2l/libi2l_dna.a $PREFIX/lib
