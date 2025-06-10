#!/bin/bash

INSTALL_FOLDER="$PREFIX/share"
BIN_FOLDER="$PREFIX/bin"
mkdir -p $INSTALL_FOLDER
mkdir -p "$INSTALL_FOLDER/resources/Data/Tables"
mkdir -p "$INSTALL_FOLDER/resources/Data/FASTA"
mkdir -p $BIN_FOLDER

cp -rf workflow $INSTALL_FOLDER/
cp -rf config $INSTALL_FOLDER/
cp -rf resources/Data/Tables/* $INSTALL_FOLDER/resources/Data/Tables/
cp -rf resources/Data/FASTA/* $INSTALL_FOLDER/resources/Data/FASTA/
install -v -m 755 m-party.py "$INSTALL_FOLDER"

install -v -m 755 $INSTALL_FOLDER/workflow/scripts/*.py "$BIN_FOLDER"
# for testing
cp -rf resources/Data/FASTA/polymerase_DB.fasta $INSTALL_FOLDER
cp -rf resources/Data/FASTA/human_gut_metagenome.fasta $INSTALL_FOLDER/resources/Data/FASTA/

ls -l $INSTALL_FOLDER
ls -l $BIN_FOLDER
ln -sf $INSTALL_FOLDER/m-party.py $BIN_FOLDER/m-party
