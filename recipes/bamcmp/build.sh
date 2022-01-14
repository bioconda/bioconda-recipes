#!/bin/bash

echo current working directory: $SRC_DIR
echo working directory contents: `ls`
echo is g++ present:
g++ --help || true
echo
echo conda_build.sh contents:
cat /opt/conda/conda-bld/bamcmp_*/work/conda_build.sh || true

cd bamcmp-2.1 || true
make
cp build/bamcmp $PREFIX/bin
