#!/bin/bash
set -x -e

mkdir -p "${PREFIX}/bin"

export CXXFLAGS="$CXXFLAGS -std=c++14"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I${PREFIX}/include/bamtools"

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

case $(uname -s) in
    "Darwin")
	sed -i.bak 's|tr1/unordered_map|unordered_map|g' src/*.cc
	sed -i.bak 's|tr1::unordered_map|unordered_map|g' src/*.cc
	;;
esac
sed -i.bak "s#g++#$CXX#g" src/CMakeLists.txt
rm -f src/*.bak

mkdir -p build
cd build

cmake -S ../src -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBOOST_ROOT="${PREFIX}" \
	-DBAMTOOLS_INCLUDE_DIR="${PREFIX}/include/bamtools" \
	-DBAMTOOLS_LIB_DIR="${PREFIX}/lib"

make

cd ..

install -v -m 0755 TransComb build/Assemble build/CorrectName build/Pre_Alignment "$PREFIX/bin"
