#!/bin/bash

# Copy shell script to bin
mkdir -p $PREFIX/bin
cp SCRIPT/ShigaPass.sh $PREFIX/bin

# Create folder to copy database to
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db
touch ${target}/db/.empty

# Unzip test files
gunzip Example/Input/*.fasta.gz

# Build index
bash SCRIPT/ShigaPass.sh -l Example/Input/ShigaPass_test.txt -o Example/ShigaPass_Results -p SCRIPT/ShigaPass_DataBases -u -k

# Copy ShigaPass db to target
cp -r SCRIPT/ShigaPass_DataBases/* ${target}/db

# Set ShigaPass DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/shigapass.sh
export SP_DB_PATH=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/shigapass.sh
unset SP_DB_PATH
EOF
