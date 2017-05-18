#!/bin/bash

set -efu -o pipefail

mkdir -p build
pushd build

mkdir -p $PREFIX/bin

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBoost_NO_BOOST_CMAKE=TRUE -DBoost_NO_SYSTEM_PATHS=TRUE -DBOOST_ROOT:PATHNAME=$PREFIX -DBoost_LIBRARY_DIRS:FILEPATH=${PREFIX}/lib ${SRC_DIR}
make Gap2Seq GapCutter GapMerger
chmod u+x Gap2Seq.sh
echo copying files: Gap2Seq.sh Gap2Seq GapCutter GapMerger $PREFIX/bin
cp Gap2Seq.sh Gap2Seq GapCutter GapMerger $PREFIX/bin
popd
