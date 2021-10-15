#!/bin/bash

if [ ! -d $PREFIX/bin ] ; then
	mkdir $PREFIX/bin
fi

mv scripts/GenFSGopher.pl $PREFIX/bin
chmod a+x $PREFIX/bin/GenFSGopher.pl

SHARE_DIR=$PREFIX/share/$PKG_NAME
if [ ! -d $SHARE_DIR ] ; then
	mkdir -p $SHARE_DIR
fi
cp -r datasets/* $SHARE_DIR
