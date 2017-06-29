#!/bin/bash

cp -R ./* $PREFIX/

echo '#!/usr/bin/env python' > $PREFIX/RNASeq-MATS.py
cat ./RNASeq-MATS.py >> $PREFIX/RNASeq-MATS.py

mv $PREFIX/RNASeq-MATS.py $PREFIX/bin/RNASeq-MATS.py

rm -rf $PREFIX/testData $PREFIX/gtf
rm $PREFIX/testRun.sh
