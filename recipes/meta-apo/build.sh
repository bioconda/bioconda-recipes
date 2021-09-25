#!/bin/bash
mkdir -p ${PREFIX}/bin

make 

cp -r bin/* ${PREFIX}/bin


PKG_NAME=meta-apo
PKG_VERSION=v1.1

MetaApo_path=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${MetaApo_path}

cp -r databases ${MetaApo_path}/databases

# set VIBRANT DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/meta-apo.sh
export MetaApo=${MetaApo_path}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/meta-apo.sh
unset MetaApo
EOF
