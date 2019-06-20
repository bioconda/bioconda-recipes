#!/bin/bash

set -ef -o pipefail

export CPPFLAGS="$CPPFLAGS -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

mkdir -p build
pushd build

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
		ln -s ${PREFIX}/include/boost ../thirdparty/gatb-core/thirdparty/

    # c++11 compatibility

		CXXFLAGS="$CXXFLAGS";
		LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";

    export CXXFLAGS="$CXXFLAGS -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
    export CXX_FLAGS="${CXX_FLAGS} -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
    export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
    export LDFLAGS="$LDFLAGS -stdlib=libc++"
    export LD_FLAGS="${LD_FLAGS} -stdlib=libc++"
    export CMAKE_LDFLAGS="${CMAKE_LDFLAGS} -stdlib=libc++"

		export C_INCLUDE_PATH=${PREFIX}/include
		export CPLUS_INCLUDE_PATH=${PREFIX}/include
		export BOOST_ROOT=${PREFIX}

    export CXX=clang++
    export CC=clang
fi

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ${SRC_DIR}
make Gap2Seq GapCutter GapMerger
chmod u+x Gap2Seq.sh
cp Gap2Seq.sh Gap2Seq GapCutter GapMerger $PREFIX/bin
popd
