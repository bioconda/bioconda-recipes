#!/bin/bash
# Copy scripts
mkdir -p ${PREFIX}/bin
chmod +x scripts/*.pl
cp scripts/*.pl ${PREFIX}/bin/
cp scripts/*.pm ${PREFIX}/bin/
cp scripts/*.py ${PREFIX}/bin/
cp -r scripts/cfg/ ${PREFIX}/bin/

# install TSEBRA
cp tsebra/bin/* ${PREFIX}/bin
mkdir -p ${SP_DIR}/tsebra_mod
mv tsebra/bin/* ${SP_DIR}/tsebra_mod
mkdir ${PREFIX}/config
mv tsebra/config/* ${PREFIX}/config
