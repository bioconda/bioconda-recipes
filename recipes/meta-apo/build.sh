#!/bin/bash
mkdir -p ${PREFIX}/bin

make 

cp -r bin/* ${PREFIX}/bin


PKG_NAME=meta-apo
PKG_VERSION=v1.1

# path for meta-apo database and example
MetaApo_path=${HOME}/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${MetaApo_path}

# set VIBRANT DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/meta-apo.sh
export MetaApo=${MetaApo_path}

if [ -f "$MetaApo_path/databases/db.config" ];then
    echo "11"
else
    echo "DB file not exsit, start downloading..."
    rm -rf "$MetaApo_path"
    wget -P "$MetaApo_path" "http://bioinfo.single-cell.cn/Released_Software/meta-apo/conda_test.tar.gz"
    tar -xzvf "$MetaApo_path/conda_test.tar.gz" -C "$MetaApo_path"
fi
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/meta-apo.sh
unset MetaApo
EOF
