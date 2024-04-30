#!/usr/bin/env bash

# Compile FCC
cd src/
git clone https://github.com/haddocking/fcc.git
cd fcc/src
chmod u+x Makefile
make \
    CPP="${CXX}"
cd $SRC_DIR

# Compile fast-rmsdmatrix
cd src/
git clone https://github.com/mgiulini/fast-rmsdmatrix.git
cd fast-rmsdmatrix/src
chmod u+x Makefile
make \
    CC="${CC}"
cd $SRC_DIR

${PYTHON} setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin
mkdir -p $SRC_DIR/bin
