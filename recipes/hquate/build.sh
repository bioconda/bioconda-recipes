#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/examples

cd $SRC_DIR
echo "Installing executable scripts..."
cp bin/AbnormalERVDetection.sh ${PREFIX}/bin/
cp bin/abnormal_ERVs.py ${PREFIX}/bin/
cp bin/ByJointProbability.sh ${PREFIX}/bin/
cp bin/ByTEAnnotation.sh ${PREFIX}/bin/
cp bin/ByTEConsensus_SubFamily.sh ${PREFIX}/bin/
cp bin/ByTESubfamily.sh ${PREFIX}/bin/
cp bin/ERVFamily ${PREFIX}/bin/
cp bin/expTEsub_cattle ${PREFIX}/bin/
cp bin/expTEsub_chicken ${PREFIX}/bin/
cp bin/expTEsub_goat ${PREFIX}/bin/
cp bin/expTEsub_pig ${PREFIX}/bin/
cp bin/expTEsub_sheep ${PREFIX}/bin/
cp bin/filterGFF ${PREFIX}/bin/
cp bin/insideConnection.sh ${PREFIX}/bin/
cp bin/HQuaTE ${PREFIX}/bin/HQuaTE
cp bin/HQuaTE ${PREFIX}/bin/hquate
cp examples/test.bam ${PREFIX}/examples/
cp examples/testTE.gff ${PREFIX}/examples/

chmod +x ${PREFIX}/bin/HQuaTE
chmod +x ${PREFIX}/bin/hquate
chmod +x ${PREFIX}/bin/filterGFF

