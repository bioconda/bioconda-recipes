#!/bin/bash

mkdir -p $PREFIX/bin

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi	

make -C zstd/lib ZSTD_LEGACY_SUPPORT=0 ZSTD_LIB_DEPRECATED=0 ZSTD_LIB_DICTBUILDER=0 libzstd.a

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	"${CONFIG_ARGS}"
cmake --build build --target ffc -j "${CPU_COUNT}" -v

chmod 0755 build/ffc
cp -rf build/ffc $PREFIX/bin
