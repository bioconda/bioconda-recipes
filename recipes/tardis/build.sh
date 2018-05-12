#!/bin/bash

python setup.py install --single-version-externally-managed --record record.txt

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

BIN=$PREFIX/bin
mkdir -p $BIN
make -C kseq_split
cp $SRC_DIR/kseq_split/kseq_split $SRC_DIR/kseq_split/kseq_count $BIN
