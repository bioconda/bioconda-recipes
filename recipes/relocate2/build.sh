#!/bin/bash

export PATH="$PREFIX/bin:$PATH"
export PYTHONPATH="$PREFIX/lib/python2.7/site-packages:$PYTHONPATH"
mkdir $PREFIX/scripts
cp ./scripts/*.p* $PREFIX/scripts
cp ./scripts/*.p* $PREFIX/bin
cp ./README.md $PREFIX
cp ./test_data.tar.gz $PREFIX
echo "bwa=$PREFIX/bin/bwa" >> $PREFIX/CONFIG
echo "bowtie2=$PREFIX/bin/bowtie2" >> $PREFIX/CONFIG
echo "bowtie2_build=$PREFIX/bin/bowtie2-build" >> $PREFIX/CONFIG
echo "blat=$PREFIX/bin/blat" >> $PREFIX/CONFIG
echo "samtools=$PREFIX/bin/samtools" >> $PREFIX/CONFIG
echo "bedtools=$PREFIX/bin/bedtools" >> $PREFIX/CONFIG
echo "seqtk=$PREFIX/bin/seqtk" >> $PREFIX/CONFIG

