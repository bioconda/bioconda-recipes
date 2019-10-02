#!/bin/bash
# Goalign executable
mkdir -p $PREFIX/bin
chmod a+x goalign_*
cp goalign_* $PREFIX/bin/goalign

# Goalign test script
wget https://raw.githubusercontent.com/evolbioinfo/goalign/v${PKG_VERSION}/test.sh
chmod a+x test.sh
sed 's+GOALIGN=./goalign+GOALIGN=goalign+g' test.sh | sed "s+TESTDATA=\"tests/data\"+TESTDATA=$PREFIX/goalign_test_data+g"  > $PREFIX/bin/goalign_test.sh

# Goalign test data
mkdir  $PREFIX/goalign_test_data
wget https://github.com/evolbioinfo/goalign/raw/v${PKG_VERSION}/tests/data/test_distance.phy.gz
wget https://github.com/evolbioinfo/goalign/raw/v${PKG_VERSION}/tests/data/test_rawdistance.phy.gz
wget https://github.com/evolbioinfo/goalign/raw/v${PKG_VERSION}/tests/data/test_rawdistance2.phy.gz
mv test_* $PREFIX/goalign_test_data
