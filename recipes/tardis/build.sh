#!/bin/bash

python setup.py install --single-version-externally-managed --record record.txt

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

BIN=$PREFIX/bin
mkdir -p $BIN
make -C kseq_split
make -C kseq_count
cp $SRC_DIR/kseq_split/kseq_split $BIN
cp $SRC_DIR/kseq_split/kseq_count $BIN
