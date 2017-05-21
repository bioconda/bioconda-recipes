#!/bin/bash

set -efu -o pipefail

echo BUILDING GAP2SEQ
echo uname is:
uname -a
echo env is:
env
echo ======================================== end of env =================================

if [ -z "$CPPFLAGS" ]; then export CPPFLAGS=""; fi
if [ -z "$LDFLAGS" ]; then export LDFLAGS=""; fi

export CPPFLAGS="$CPPFLAGS -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

mkdir -p build
pushd build

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    # c++11 compatibility

		if [ -z "$CXXFLAGS" ]; then export CXXFLAGS=""; fi
		if [ -z "${CXX_FLAGS}" ]; then export CXX_FLAGS=""; fi
		if [ -z "${CMAKE_CXX_FLAGS}" ]; then export CMAKE_CXX_FLAGS=""; fi
		if [ -z "${LDFLAGS}" ]; then export LDFLAGS=""; fi
		if [ -z "${LD_FLAGS}" ]; then export LD_FLAGS=""; fi
		if [ -z "${CMAKE_LD_FLAGS}" ]; then export CMAKE_LD_FLAGS=""; fi

    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    export CXX_FLAGS="${CXX_FLAGS} -stdlib=libc++"
    export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -stdlib=libc++"
    export LDFLAGS="$LDFLAGS -stdlib=libc++"
    export LD_FLAGS="${LD_FLAGS} -stdlib=libc++"
    export CMAKE_LDFLAGS="${CMAKE_LDFLAGS} -stdlib=libc++"
		echo "gap2seq build - Darwin detected - env is"
		env
		echo "gap2seq build - end of env"
else
		echo "gap2seq build - Darwin NOT detected - env not changed"
fi


cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBoost_NO_BOOST_CMAKE=TRUE -DBoost_NO_SYSTEM_PATHS=TRUE -DBOOST_ROOT:PATHNAME=$PREFIX -DBoost_LIBRARY_DIRS:FILEPATH=${PREFIX}/lib ${SRC_DIR}
make Gap2Seq GapCutter GapMerger
chmod u+x Gap2Seq.sh
echo copying files: Gap2Seq.sh Gap2Seq GapCutter GapMerger $PREFIX/bin
cp Gap2Seq.sh Gap2Seq GapCutter GapMerger $PREFIX/bin
popd
