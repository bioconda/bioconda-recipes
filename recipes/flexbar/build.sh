#!/bin/bash

wget https://github.com/seqan/seqan/releases/download/seqan-v2.4.0/seqan-library-2.4.0.tar.xz
tar -xf seqan-library-2.4.0.tar.xz

mv seqan-library-2.4.0/include "${SRC_DIR}"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}"
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build --clean-first -j "${CPU_COUNT}"

install -v -m 0755 build/flexbar "$PREFIX/bin"
mkdir -p $PREFIX/share/doc/flexbar
cp -f build/*.md $PREFIX/share/doc/flexbar
