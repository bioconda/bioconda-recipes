#!/bin/bash

mkdir -p $SP_DIR/
mkdir -p $SP_DIR/cnn
mkdir -p $SP_DIR/cnn/cnn_chkpnt
mkdir -p $SP_DIR/finetune

cp src/cnn/cnn_chkpnt/model.pt $SP_DIR/cnn/cnn_chkpnt/
cp src/finetune/Phrostt5_finetuned.pth $SP_DIR/finetune/

