#!/bin/bash

echo '#!/usr/bin/env python' | cat - RNASeq-MATS.py > tmp
mv tmp RNASeq-MATS.py
rmats_path = $PREFIX/share/$PKG_NAME
sed -i -e "s/scriptPath +/$rmats_path +/g" RNASeq-MATS.py
sed -i':a;N;$!ba;s/else: ## bam file was provided.*sys.exit();//g' ~/RNASeq-MATS.py 
rm -rf testData test.bam.sh testRun.sh gtf
mkdir -p $PREFIX/bin
cp RNASeq-MATS.py $PREFIX/bin/
cp -R $SRC_DIR/ $PREFIX/share/$PKG_NAME
