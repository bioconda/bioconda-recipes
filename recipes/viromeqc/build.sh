#!/bin/sh
set -e

echo "Building viromeqc..."

cp -r $SRC_DIR/* $PREFIX/bin/

cd $PREFIX/bin
echo $(pwd)
echo $(ls)

chmod +x viromeQC.py
chmod +x fastq_len_filter.py