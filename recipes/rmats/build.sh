#!/bin/bash

mkdir $PREFIX/rMATS
cp -R ./* $PREFIX/rMATS

echo '#!/bin/bash' > $PREFIX/bin/RNASeq-MATS.py
echo 'RMATS_INSTALL_DIR=$(dirname $(dirname "$0"))/rMATS' >> $PREFIX/bin/RNASeq-MATS.py
echo 'python $RMATS_INSTALL_DIR/RNASeq-MATS.py "$@"' >> $PREFIX/bin/RNASeq-MATS.py
chmod +x $PREFIX/bin/RNASeq-MATS.py

rm -rf $PREFIX/rMATS/testData $PREFIX/rMATS/gtf
rm $PREFIX/rMATS/testRun.sh
