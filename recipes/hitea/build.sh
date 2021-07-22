#!/bin/bash

INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER
mkdir -p $BIN_FOLDER

## Copy installables to proper installation folder
cp -r hg38 $INSTALL_FOLDER/
cp -r hg19 $INSTALL_FOLDER/
cp -r src $INSTALL_FOLDER/
cp -r examples $INSTALL_FOLDER/
cp LICENSE.txt $INSTALL_FOLDER/
cp test.sh $INSTALL_FOLDER/
cp hitea $INSTALL_FOLDER/

chmod 755 $INSTALL_FOLDER/hitea

ls -lt $INSTALL_FOLDER

## create bin folder link to hitea
ln -s $INSTALL_FOLDER/hitea $BIN_FOLDER/hitea

#export PATH=$PATH:$INSTALL_FOLDER
#export PATH=$INSTALL_FOLDER
