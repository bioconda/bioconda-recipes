#!/usr/bin/env bash
set -xe
df -h
du -sch $CONDA_PREFIX
mkdir -p $PREFIX/bin
cp -rf $SRC_DIR/bin $PREFIX/bin
cp -rf $SRC_DIR/scripts $PREFIX/bin
df -h
cp $SRC_DIR/SynGAP.py $PREFIX/bin
cp $SRC_DIR/initdb.py $PREFIX/bin
df -h
cp $SRC_DIR/master.py $PREFIX/bin
cp $SRC_DIR/dual.py $PREFIX/bin
cp $SRC_DIR/triple.py $PREFIX/bin
cp $SRC_DIR/custom.py $PREFIX/bin
df -h
cp $SRC_DIR/genepair.py $PREFIX/bin
cp $SRC_DIR/evi.py $PREFIX/bin
cp $SRC_DIR/eviplot.py $PREFIX/bin
df -h
