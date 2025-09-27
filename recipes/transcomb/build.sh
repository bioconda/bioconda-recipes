#!/bin/bash
set -x -e

mkdir -p "${PREFIX}/bin"

export LIBS='-lboost_regex -lboost_system -lboost_program_options -lboost_filesystem -lboost_timer'
export CXXFLAGS="$CXXFLAGS -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="$LDFLAGS -L${BOOST_LIBRARY_DIR} -lboost_regex -lboost_filesystem -lboost_system"

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

sed -i.bak "s#g++#$CXX#g" src/CMakeLists.txt
rm -f src/*.bak

mkdir -p build
cd build

cmake -S ../src -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS -std=c++14" \
	-DBOOST_ROOT="${PREFIX}" \
	-DBAMTOOLS_INCLUDE_DIR="${PREFIX}/include/bamtools" \
	-DBAMTOOLS_LIB_DIR="${PREFIX}/lib"

make

cd ..

install -v -m 0755 TransComb build/Assemble build/CorrectName build/Pre_Alignment "$PREFIX/bin"
