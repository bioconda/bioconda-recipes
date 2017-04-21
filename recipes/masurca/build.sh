#!/bin/bash
		
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM		
mkdir -p $outdir		
mkdir -p $PREFIX/bin		
cd $SRC_DIR		
$SRC_DIR
export DEST=$PREFIX
./install.sh
