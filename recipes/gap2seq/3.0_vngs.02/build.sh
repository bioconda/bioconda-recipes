#!/bin/bash

set -ef -o pipefail -x

git submodule init
git submodule update --recursive

export CPPFLAGS="$CPPFLAGS -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

#pushd thirdparty/htslib
#autoreconf
#./configure --disable-bz2 --disable-lzma --disable-libcurl --disable-gcs --disable-s3
#make -j${CPU_COUNT} CPPFLAGS="-I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib" lib-static
#popd

mkdir -p build
pushd build

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
		#ln -s ${PREFIX}/include/boost ${SRC_DIR}/thirdparty/gatb-core/thirdparty/

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

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_C_FLAGS=-I${PREFIX}/include -DCMAKE_CXX_FLAGS=-I${PREFIX}/include \
			-DCMAKE_SHARED_LINKER_FLAGS=-L${PREFIX}/lib -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib  \
			-DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
			-DBUILD_SHARED_LIBS=OFF ${SRC_DIR}

make -j${CPU_COUNT} VERBOSE=1 Gap2Seq-core GapCutter GapMerger ReadFilter
echo COMPILATION WORKED
#make VERBOSE=1 install
cp Gap2Seq-core GapCutter GapMerger ReadFilter ${PREFIX}/bin/
cp ${SRC_DIR}/src/Gap2Seq.py ${PREFIX}/bin/Gap2Seq
chmod u+x ${PREFIX}/bin/Gap2Seq
echo PREFIX is $PREFIX
ls -alt ${PREFIX}/bin
popd
