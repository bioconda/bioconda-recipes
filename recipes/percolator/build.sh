#!/bin/bash

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cmake -S . -B percobuild \
	-DTARGET_ARCH=$(uname -m) -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$PREFIX" -DXML_SUPPORT=ON \
	-DCMAKE_PREFIX_PATH="$PREFIX;$PREFIX/lib" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -std=c++14 -O3 -I{PREFIX}/include"
cmake --build percobuild/ --target install -v

# First make sure we dont get problems with truncated PREFIX due to null terminators:
# see percolator/percolator#251 and conda/conda-build#1674
sed -i.bak '54s/WRITABLE_DIR/std::string(WRITABLE_DIR).c_str()/' $SRC_DIR/src/Globals.cpp
 
cmake -S ${SRC_DIR}/src/converters -B converterbuild \
	-DTARGET_ARCH=$(uname -m) -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$PREFIX" -DBOOST_ROOT="$PREFIX" \
	-DBOOST_LIBRARYDIR="$PREFIX/lib" -DSERIALIZE="Boost" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -std=c++14 -O3 -I{PREFIX}/include" \
	-DCMAKE_PREFIX_PATH="$PREFIX" -DCMAKE_CXX_COMPILER="${CXX}"
cmake --build converterbuild/ --target install -v

mkdir -p $PREFIX/testdata
cp -f $SRC_DIR/src/converters/data/converters/sqt2pin/target.sqt $PREFIX/testdata/target.sqt
cp -f $SRC_DIR/src/converters/data/converters/msgf2pin/target.mzid $PREFIX/testdata/target.mzid
cp -f $SRC_DIR/src/converters/data/converters/tandem2pin/target.t.xml $PREFIX/testdata/target.t.xml
cp -f $SRC_DIR/data/percolator/tab/percolatorTab $PREFIX/testdata/percolatorTab
