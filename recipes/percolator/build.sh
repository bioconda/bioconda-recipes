#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++14 -O3"

sed -i.bak 's|VERSION 2.6|VERSION 3.5|' src/converters/CMakeLists.txt
rm -rf src/converters/*.bak

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B percobuild \
	-DTARGET_ARCH=$(uname -m) -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DXML_SUPPORT=ON \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	-DGOOGLE_TEST=ON -DPROFILING=ON "${CONFIG_ARGS}"
cmake --build percobuild/ --clean-first --target install -j "${CPU_COUNT}"

# First make sure we dont get problems with truncated PREFIX due to null terminators:
# see percolator/percolator#251 and conda/conda-build#1674
sed -i.bak '54s/WRITABLE_DIR/std::string(WRITABLE_DIR).c_str()/' $SRC_DIR/src/Globals.cpp
rm -rf $SRC_DIR/src/*.bak

cmake -S ${SRC_DIR}/src/converters -B converterbuild \
	-DTARGET_ARCH=$(uname -m) -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DBOOST_ROOT="${PREFIX}" \
	-DBOOST_LIBRARYDIR="${PREFIX}/lib" -DSERIALIZE="Boost" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_PREFIX_PATH="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	-DXML_SUPPORT=ON -DPROFILING=ON "${CONFIG_ARGS}"
cmake --build converterbuild/ --clean-first --target install -j "${CPU_COUNT}"

mkdir -p $PREFIX/testdata
cp -f $SRC_DIR/src/converters/data/converters/sqt2pin/target.sqt $PREFIX/testdata/target.sqt
cp -f $SRC_DIR/src/converters/data/converters/msgf2pin/target.mzid $PREFIX/testdata/target.mzid
cp -f $SRC_DIR/src/converters/data/converters/tandem2pin/target.t.xml $PREFIX/testdata/target.t.xml
cp -f $SRC_DIR/data/percolator/tab/percolatorTab $PREFIX/testdata/percolatorTab
