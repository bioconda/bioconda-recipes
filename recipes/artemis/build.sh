#!/bin/bash

INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER
mkdir -p $BIN_FOLDER

#
# Copy installables to proper installation folder
#
cp -r etc $INSTALL_FOLDER/
cp -r dist $INSTALL_FOLDER/
cp art $INSTALL_FOLDER/
cp act $INSTALL_FOLDER/
cp dnaplotter $INSTALL_FOLDER/
cp bamview $INSTALL_FOLDER/
cp LICENSE $INSTALL_FOLDER/
cp AUTHORS $INSTALL_FOLDER/
ls -lt $INSTALL_FOLDER

#
# Create bin folder links to scripts
#
ln -s $INSTALL_FOLDER/art $BIN_FOLDER/art
ln -s $INSTALL_FOLDER/act $BIN_FOLDER/act
ln -s $INSTALL_FOLDER/dnaplotter $BIN_FOLDER/dnaplotter
ln -s $INSTALL_FOLDER/bamview $BIN_FOLDER/bamview
ln -s $INSTALL_FOLDER/etc/writedb_entry $BIN_FOLDER/writedb_entry

# List installables
#echo "List artemis install folder"
#ls -lt $INSTALL_FOLDER
#echo "List artemis bin folder"
#ls -lt $BIN_FOLDER

