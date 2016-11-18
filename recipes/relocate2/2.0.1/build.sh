#!/bin/bash

mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/bin
cp $SRC_DIR/scripts/*.p* $PREFIX/scripts
cp $SRC_DIR/scripts/*.p* $PREFIX/bin
chmod 755 $PREFIX/scripts/*
cp $SRC_DIR/README.md $PREFIX
cp -R $SRC_DIR/test_data $PREFIX
echo "bwa=$PREFIX/bin/bwa" >> $PREFIX/CONFIG
echo "bowtie2=$PREFIX/bin/bowtie2" >> $PREFIX/CONFIG
echo "bowtie2_build=$PREFIX/bin/bowtie2-build" >> $PREFIX/CONFIG
echo "blat=$PREFIX/bin/blat" >> $PREFIX/CONFIG
echo "samtools=$PREFIX/bin/samtools" >> $PREFIX/CONFIG
echo "bedtools=$PREFIX/bin/bedtools" >> $PREFIX/CONFIG
echo "seqtk=$PREFIX/bin/seqtk" >> $PREFIX/CONFIG

