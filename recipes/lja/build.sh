#!/bin/bash

set -e
mkdir -p "${PREFIX}/bin"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	sed -i.bak 's/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS}" )/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -ggdb3 ${OpenMP_CXX_FLAGS}" )/g' $SRC_DIR/CMakeLists.txt
	rm -rf *.bak
else
	export CONFIG_ARGS=""
	sed -i.bak 's/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS}" )/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -lstdc++fs -ggdb3 ${OpenMP_CXX_FLAGS} -lrt" )/g' $SRC_DIR/CMakeLists.txt
	rm -rf *.bak
fi

echo "Building LJA..."

cd $SRC_DIR
cp -rf ${RECIPE_DIR}/py .

echo "cmake -S $SRC_DIR"
cmake -S $SRC_DIR -B "$SRC_DIR/build" -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" "${CONFIG_ARGS}"

echo "cmake install"
cmake --build "$SRC_DIR/build" --target install -j "${CPU_COUNT}"

install -v -m 0755 bin/lja "${PREFIX}/bin"

#cp -rf $SRC_DIR/bin $PREFIX
#cp -rf $SRC_DIR/src $PREFIX
