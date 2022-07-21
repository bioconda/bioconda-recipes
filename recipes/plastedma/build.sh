#!/bin/bash

INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER
mkdir -p $BIN_FOLDER

cp -r workflow $INSTALL_FOLDER/
cp -r config $INSTALL_FOLDER/
cp -r resources $INSTALL_FOLDER/
cp -r results $INSTALL_FOLDER/
cp plastedma.py $INSTALL_FOLDER/
echo "Listing copied files from package to install folder"
ls -lt $INSTALL_FOLDER

ln -s $INSTALL_FOLDER/plastedma.py $BIN_FOLDER/
ln -s $INSTALL_FOLDER/workflow/ $BIN_FOLDER/
echo "Listing bin folder links from install folder"
ls -l $BIN_FOLDER
chmod +x $BIN_FOLDER/plastedma.py