#!/bin/bash

mkdir -p $PREFIX/bin

CDIR=`pwd`

cd Graph2Pro
make clean
make

cd $CDIR

cp Graph2Pro/DBGraph2Pro $PREFIX/bin/DBGraph2Pro
cp Graph2Pro/DBGraphPep2Pro $PREFIX/bin/DBGraphPep2Pro
