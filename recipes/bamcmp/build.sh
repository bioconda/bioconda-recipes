#!/bin/bash


echo conda_build.sh contents:
cat /opt/conda/conda-bld/bamcmp_*/work/conda_build.sh || true


ls -lah
pwd
cd bamcmp-2.1 || true
ls -lah
pwd 
make CPP=$CC
pwd
cp build/bamcmp $PREFIX/bin
