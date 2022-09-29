#!/bin/bash

INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER/workflow/scripts
mkdir -p $BIN_FOLDER

cp -r workflow/scripts/* $INSTALL_FOLDER/workflow/scripts
cp -r config $INSTALL_FOLDER/
cp -r resources $INSTALL_FOLDER/
cp -r results $INSTALL_FOLDER/
cp plastedma.py $INSTALL_FOLDER/
#ls -lt $INSTALL_FOLDER/workflow

cp -r $INSTALL_FOLDER/workflow/scripts/* $BIN_FOLDER
chmod u+rx $INSTALL_FOLDER/plastedma.py
echo "Listing bin folder"
ls -l $BIN_FOLDER
ln -s $INSTALL_FOLDER/plastedma.py $BIN_FOLDER/
echo "Listing bin folder after simblink"
ls -l $BIN_FOLDER

echo "INSTALL FINISHED"
