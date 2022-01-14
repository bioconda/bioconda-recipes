#!/bin/bash

echo current working directory: `echo $SRC_DIR`
echo working directory contents: `ls`
echo is g++ present:
g++ --help || true
echo
echo "Compiler is: " `echo $CC`

echo conda_build.sh contents:
cat /opt/conda/conda-bld/bamcmp_*/work/conda_build.sh || true

cd bamcmp-2.1 || true
make CPP=$CC
cp build/bamcmp $PREFIX/bin
