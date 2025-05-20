#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

cp -r ${SRC_DIR} $PREFIX/lib/metacompass

cd $PREFIX/lib/metacompass
${CXX} -Wall -W -O2 -o ./bin/extractSeq ./src/utils/extractSeq.cpp
${CXX} -Wall -W -O2 -o ./bin/formatFASTA ./src/utils/formatFASTA.cpp
${CXX} -Wall -W -O2 -o ./bin/buildcontig ./src/buildcontig/buildcontig.cpp ./src/buildcontig/cmdoptions.cpp ./src/buildcontig/memory.cpp ./src/buildcontig/procmaps.cpp ./src/buildcontig/outputfiles.cpp

ln -s $PREFIX/lib/metacompass/go_metacompass.py $PREFIX/bin/go_metacompass.py
ln -s $PREFIX/lib/metacompass/bin/kmer-mask $PREFIX/bin/kmer-mask
