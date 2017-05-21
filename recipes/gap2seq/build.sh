#!/bin/bash

set -efu -o pipefail

mkdir -p build
pushd build

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    # c++11 compatibility

    export CXXFLAGS=' -stdlib=libc++'
    export CXX_FLAGS=' -stdlib=libc++'
    export CMAKE_CXX_FLAGS=' -stdlib=libc++'
    export LDFLAGS=' -stdlib=libc++'
    export LD_FLAGS=' -stdlib=libc++'
    export CMAKE_LDFLAGS=' -stdlib=libc++'
fi


cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DBoost_NO_BOOST_CMAKE=TRUE -DBoost_NO_SYSTEM_PATHS=TRUE -DBOOST_ROOT:PATHNAME=$PREFIX -DBoost_LIBRARY_DIRS:FILEPATH=${PREFIX}/lib ${SRC_DIR}
make VERBOSE=1 Gap2Seq GapCutter GapMerger
chmod u+x Gap2Seq.sh
echo copying files: Gap2Seq.sh Gap2Seq GapCutter GapMerger $PREFIX/bin
cp Gap2Seq.sh Gap2Seq GapCutter GapMerger $PREFIX/bin
popd
