#!/bin/bash

# Copy scripts
mkdir -p ${PREFIX}/bin
chmod +x scripts/*.pl
cp scripts/*.pl ${PREFIX}/bin/
cp scripts/*.pm ${PREFIX}/bin/
cp scripts/*.py ${PREFIX}/bin/
cp -r scripts/cfg/ ${PREFIX}/bin/
chmod +x gushr.py
cp gushr.py ${PREFIX}/bin/

# install TSEBRA
sed -i'' -e 's#from \([^ ]*\) import#from tsebra_mod.\1 import#' tsebra/bin/*.py
mv tsebra/bin/tsebra.py tsebra/bin/fix_gtf_ids.py ${PREFIX}/bin
mkdir -p ${SP_DIR}/tsebra_mod
mv tsebra/bin/* ${SP_DIR}/tsebra_mod
mkdir ${PREFIX}/config
mv tsebra/config/* ${PREFIX}/config
