#!/bin/bash


cp -R ./* $PREFIX/

echo '#!/usr/bin/env python' > $PREFIX/RNASeq-MATS.py
cat ./RNASeq-MATS.py >> $PREFIX/RNASeq-MATS.py

bash $PREFIX/test.bam.sh

mv $PREFIX/RNASeq-MATS.py $PREFIX/bin/RNASeq-MATS.py

rm -rf $PREFIX/testData $PREFIX/gtf
rm $PREFIX/test.bam.sh
rm $PREFIX/testRun.sh
