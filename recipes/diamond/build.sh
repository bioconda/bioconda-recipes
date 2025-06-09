#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CMAKE_C_COMPILER="${CC}"
export CMAKE_CXX_COMPILER="${CXX}"

sed -i.bak 's|VERSION 2.6|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

cd ncbi-cxx-toolkit-public
export CMAKE_ARGS="-S src -B . -DCMAKE_BUILD_TYPE=Release -Wno-dev -Wno-deprecated --no-warn-unused-cli"

sed -i.bak 's|"-msse4.2"|""|' src/build-system/cmake/toolchains/*.cmake
sed -i.bak 's|"-msse4.2"|""|' src/build-system/cmake/toolchains/*.in
rm -rf src/build-system/cmake/toolchains/*.bak

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export CONFIG_ARGS="-DARM=ON -DX86=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET="11.0" -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	export CONFIG_ARGS="-DX86=ON -DCMAKE_OSX_DEPLOYMENT_TARGET="10.15" -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export CONFIG_ARGS="-DAARCH64=ON -DX86=OFF -DBUILD_STATIC=ON"
else
	export CONFIG_ARGS="-DX86=ON -DBUILD_STATIC=ON -DWITH_AVX512=ON"
fi

./cmake-configure --without-debug \
	--with-projects="objtools/blast/seqdb_reader;objtools/blast/blastdb_format" \
 	--with-build-root=build

cd build
cmake --build build --clean-first -j"${CPU_COUNT}"

cp -rf ${SRC_DIR}/ncbi-cxx-toolkit-public/build/inc/ncbiconf_unix.h ${SRC_DIR}/ncbi-cxx-toolkit-public/include

cd ${SRC_DIR}

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DWITH_ZSTD=ON \
	-DZSTD_LIBRARY="${PREFIX}/lib/libzstd.a" -DZSTD_INCLUDE_DIR="${PREFIX}/include" \
	-DBLAST_INCLUDE_DIR="${SRC_DIR}/ncbi-cxx-toolkit-public/include" \
	-DBLAST_LIBRARY_DIR="${SRC_DIR}/ncbi-cxx-toolkit-public/build/lib" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
