#!/bin/sh
set -e
cp -r $SRC_DIR/* $PREFIX/bin/
cd $PREFIX/bin
chmod +x viromeQC.py
chmod +x fastq_len_filter.py