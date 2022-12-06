#!/bin/bash

INSTALL_FOLDER=$PREFIX/share
BIN_FOLDER=$PREFIX/bin
mkdir -p $INSTALL_FOLDER
mkdir -p $INSTALL_FOLDER/resources/Data/HMMs/PE/After_tcoffee_UPI
mkdir -p $INSTALL_FOLDER/resources/Data/FASTA/PE/CDHIT
mkdir -p $BIN_FOLDER

cp -r workflow/scripts $INSTALL_FOLDER/
cp -r config $INSTALL_FOLDER/
cp -r resources/Data/HMMs/PE/After_tcoffee_UPI/* $INSTALL_FOLDER/resources/Data/HMMs/PE/After_tcoffee_UPI/
cp -r resources/Data/FASTA/PE/CDHIT/* $INSTALL_FOLDER/resources/Data/FASTA/PE/CDHIT/
cp -r results $INSTALL_FOLDER/
cp m-party.py $INSTALL_FOLDER/
# ls -lt $INSTALL_FOLDER

cp $INSTALL_FOLDER/scripts/* $BIN_FOLDER
# for testing
cp resources/Data/FASTA/PE/literature_seq/lit_sequences.fasta $INSTALL_FOLDER
cp resources/Data/FASTA/human_gut_metagenome.fasta $INSTALL_FOLDER/resources/Data/FASTA/

ls -l $INSTALL_FOLDER
#ls -l $INSTALL_FOLDER/resources/Data/FASTA/CDHIT
#ls -l $INSTALL_FOLDER/resources/Data/HMMs&/After_tcoffee_UPI
ls -l $BIN_FOLDER
chmod u+x $INSTALL_FOLDER/m-party.py
ln -s $INSTALL_FOLDER/m-party.py $BIN_FOLDER/m-party
# chmod u+x $BIN_FOLDER/m-party.py
