#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

cp -rf ${SRC_DIR} $PREFIX/lib/metacompass

cd $PREFIX/lib/metacompass
${CXX} -Wall -W -O3 -o ./bin/extractSeq ./src/utils/extractSeq.cpp
${CXX} -Wall -W -O3 -o ./bin/formatFASTA ./src/utils/formatFASTA.cpp
${CXX} -Wall -W -O3 -o ./bin/buildcontig ./src/buildcontig/buildcontig.cpp ./src/buildcontig/cmdoptions.cpp ./src/buildcontig/memory.cpp ./src/buildcontig/procmaps.cpp ./src/buildcontig/outputfiles.cpp

ln -sf $PREFIX/lib/metacompass/go_metacompass.py $PREFIX/bin/go_metacompass.py
ln -sf $PREFIX/lib/metacompass/bin/kmer-mask $PREFIX/bin/kmer-mask
