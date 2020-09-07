#!/bin/bash

set -e

mkdir -p $PREFIX/bin

cd prodigal_modified
make CC=$CC --quiet # conda will add $CC to environment
chmod +x prodigal
cd ..

cp $SRC_DIR/prodigal_modified/prodigal $PREFIX/bin/prodigal_sm

$PYTHON -m pip install --disable-pip-version-check --no-cache-dir --ignore-installed --no-deps -vv .

