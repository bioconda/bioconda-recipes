#!/bin/bash

set -e
mkdir -p "${PREFIX}/bin"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
 	export CFLAGS="${CFLAGS} -g -Wall -O3 -stdlib=libc++ -I$PREFIX/include -L$PREFIX/lib"
	sed -i.bak 's/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS}" )/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -ggdb3 ${OpenMP_CXX_FLAGS}" )/g' $SRC_DIR/CMakeLists.txt
	rm -rf *.bak
else
	export CONFIG_ARGS=""
 	export CFLAGS="${CFLAGS} -g -Wall -O3 -I$PREFIX/include -L$PREFIX/lib""
	sed -i.bak 's/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS}" )/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS} -lrt" )/g' $SRC_DIR/CMakeLists.txt
	rm -rf *.bak
fi

echo "Building LJA..."

cd $SRC_DIR
cp -rf ${RECIPE_DIR}/py .

echo "cmake -S $SRC_DIR"
cmake -S $SRC_DIR -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" "${CONFIG_ARGS}"

echo "make"
make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 ${SRC_DIR}/bin/* "${PREFIX}/bin"
cp -rf $SRC_DIR/src "${PREFIX}"
