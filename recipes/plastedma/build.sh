#!/bin/bash

INSTALL_FOLDER=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
BIN_FOLDER=$PREFIX/bin
DATA_FOLDER=$PREFIX/bin/resources/Data
ALIGNEMTS_FOLDER=$PREFIX/bin/resources/Alignments
mkdir -p $INSTALL_FOLDER/workflow/scripts
mkdir -p $BIN_FOLDER/workflow/scripts
mkdir -p $DATA_FOLDER/HMMs/After_tcoffee_UPI
mkdir -p $DATA_FOLDER/FASTA/CDHIT
mkdir -p $ALIGNEMTS_FOLDER

cp -r workflow/scripts/* $INSTALL_FOLDER/workflow/scripts
cp -r config $INSTALL_FOLDER/
cp -r resources $INSTALL_FOLDER/
cp -r results $INSTALL_FOLDER/
cp plastedma.py $INSTALL_FOLDER/
#ls -lt $INSTALL_FOLDER/workflow

cp -r $INSTALL_FOLDER/workflow/scripts/* $BIN_FOLDER/workflow/scripts
# for testing
cp $INSTALL_FOLDER/resources/Data/FASTA/literature_seq/lit_sequences.fasta $BIN_FOLDER
# for negative control validation
cp $INSTALL_FOLDER/resources/Data/FASTA/human_gut_metagenome.fasta $BIN_FOLDER
# in built models must be present in tool backbone
cp -r $INSTALL_FOLDER/resources/Data/HMMs/After_tcoffee_UPI/* $DATA_FOLDER/HMMs/After_tcoffee_UPI
# also the sequences that originated the models
cp -r $INSTALL_FOLDER/resources/Data/FASTA/CDHIT/* $DATA_FOLDER/FASTA/CDHIT

ls -l $BIN_FOLDER
chmod u+rx $BIN_FOLDER/plastedma.py
ln -s $INSTALL_FOLDER/plastedma.py $BIN_FOLDER/
# ln -s $INSTALL_FOLDER/workflow $BIN_FOLDER/
# ln -s $INSTALL_FOLDER/workflow/scripts/hmmsearch_run.py $INSTALL_FOLDER/workflow/scripts/hmm_process.py $BIN_FOLDER/
