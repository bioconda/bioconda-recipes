#!/bin/sh
ln -s $SAMTOOLS_ROOT_DIR/src samtools
cp $SAMTOOLS_ROOT_DIR/lib/libbam.* samtools/
make
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin
