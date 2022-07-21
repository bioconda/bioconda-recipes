#!/bin/bash

INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER
mkdir -p $BIN_FOLDER
mkdir -p $BIN_FOLDER/workflow/scripts

cp -r workflow $INSTALL_FOLDER/
cp -r config $INSTALL_FOLDER/
cp -r resources $INSTALL_FOLDER/
cp -r results $INSTALL_FOLDER/
cp plastedma.py $INSTALL_FOLDER/
echo "Listing copied files from package to install folder"
ls -lt $INSTALL_FOLDER/workflow

cp $INSTALL_FOLDER/workflow/scripts/hmmsearch_run.py $INSTALL_FOLDER/workflow/scripts/hmm_process.py $BIN_FOLDER/workflow/scripts
ls -l $BIN_FOLDER
ls -l $BIN_FOLDER/workflow/
ls -l $BIN_FOLDER/workflow/scripts
ln -s $INSTALL_FOLDER/plastedma.py $BIN_FOLDER/
# ln -s $INSTALL_FOLDER/workflow/scripts/hmmsearch_run.py $INSTALL_FOLDER/workflow/scripts/hmm_process.py $BIN_FOLDER/
echo "Listing bin folder links from install folder"
chmod u+x $BIN_FOLDER/*