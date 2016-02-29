#!/bin/bash

echo '#!/usr/bin/env python' | cat - RNASeq-MATS.py > tmp
mv tmp RNASeq-MATS.py
rm -rf testData test.bam.sh testRun.sh gtf
mkdir -p $PREFIX/bin
cp -R $SRC_DIR $PREFIX/bin/$PKG_NAME
