#!/bin/bash

INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER
mkdir -p $BIN_FOLDER
# mkdir -p $BIN_FOLDER/workflow/scripts

cp -r workflow/scripts/* $INSTALL_FOLDER/
cp -r config/* $INSTALL_FOLDER/
cp -r resources $INSTALL_FOLDER/
cp -r results $INSTALL_FOLDER/
cp plastedma.py $INSTALL_FOLDER/
echo "Listing copied files from package to install folder"
#ls -lt $INSTALL_FOLDER/workflow

# cp $INSTALL_FOLDER/workflow/scripts/hmmsearch_run.py $INSTALL_FOLDER/workflow/scripts/hmm_process.py $BIN_FOLDER/workflow/scripts
ls -l $BIN_FOLDER
ln -s $INSTALL_FOLDER/plastedma.py $BIN_FOLDER/
#ln -s $INSTALL_FOLDER/workflow $BIN_FOLDER/
# ln -s $INSTALL_FOLDER/workflow/scripts/hmmsearch_run.py $INSTALL_FOLDER/workflow/scripts/hmm_process.py $BIN_FOLDER/
chmod u+x $BIN_FOLDER/plastedma.py