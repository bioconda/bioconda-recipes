#!/bin/bash

INSTALL_FOLDER=$PREFIX/share
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER
mkdir -p $INSTALL_FOLDER/resources/Data/Tables
mkdir -p $INSTALL_FOLDER/resources/Data/FASTA
mkdir -p $BIN_FOLDER

cp -rf workflow/scripts $INSTALL_FOLDER/
cp -rf config $INSTALL_FOLDER/
cp -rf resources/Data/Tables/* $INSTALL_FOLDER/resources/Data/Tables/
cp -rf resources/Data/FASTA/* $INSTALL_FOLDER/resources/Data/FASTA/
cp -f m-party.py $INSTALL_FOLDER/

cp -rf $INSTALL_FOLDER/scripts/* $BIN_FOLDER
# for testing
cp -rf resources/Data/FASTA/polymerase_DB.fasta $INSTALL_FOLDER
cp -rf resources/Data/FASTA/human_gut_metagenome.fasta $INSTALL_FOLDER/resources/Data/FASTA/

ls -l $INSTALL_FOLDER
ls -l $BIN_FOLDER
chmod u+x $INSTALL_FOLDER/m-party.py
ln -sf $INSTALL_FOLDER/m-party.py $BIN_FOLDER/m-party
