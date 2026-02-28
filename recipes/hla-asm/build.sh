#!/bin/bash
BIN_DIR=$PREFIX/bin
OPT_DIR=$PREFIX/opt/hla-asm
mkdir -p $BIN_DIR
mkdir -p $OPT_DIR
cp $SRC_DIR/HLA-ASM.pl $OPT_DIR/
cp $SRC_DIR/findPath.pm $OPT_DIR/
chmod u+x $OPT_DIR/HLA-ASM.pl
ln -s $OPT_DIR/HLA-ASM.pl $BIN_DIR/HLA-ASM.pl
ln -s $OPT_DIR/findPath.pm $BIN_DIR/findPath.pm
