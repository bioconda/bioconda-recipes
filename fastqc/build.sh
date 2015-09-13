#!/bin/bash

fastqc=$PREFIX/FastQC
mkdir $fastqc
cp -r ./* $fastqc
chmod +x $fastqc/fastqc
mkdir -p $PREFIX/bin
ln -s $fastqc/fastqc $PREFIX/bin/fastqc 

