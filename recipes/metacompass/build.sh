#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

cp -r ${SRC_DIR} $PREFIX/lib/metacompass

sed -i 's/g++/${CXX}/g' $PREFIX/lib/metacompass/install.sh
chmod +x $PREFIX/lib/metacompass/install.sh
$PREFIX/lib/metacompass/install.sh

ln -s $PREFIX/lib/metacompass/go_metacompass.py $PREFIX/bin/go_metacompass.py
ln -s $PREFIX/lib/metacompass/bin/kmer-mask $PREFIX/bin/kmer-mask