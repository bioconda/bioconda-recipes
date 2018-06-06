#!/bin/bash

NCBI_VDB_VERSION=2.9.0-1
NGS_VDB_SHA256=b4099e2fc3349eaf487219fbe798b22124949c89ffa1e7e6fbaa73a5178c8aff

curl -L https://github.com/ncbi/ncbi-vdb/archive/${NCBI_VDB_VERSION}.tar.gz > ncbi-vdb-${NCBI_VDB_VERSION}.tar.gz


[[ $NGS_VDB_SHA256 == $(cat ncbi-vdb-${NCBI_VDB_VERSION}.tar.gz |shasum -a 256| cut -f1 -d ' ') ]] && echo "NCBI VDB Download success" || exit 1

mkdir -p ncbi-vdb

SRC_VDB=$SRC_DIR/ncbi-vdb/ncbi-vdb-${NCBI_VDB_VERSION}


if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

cd $SRC_VDB
./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi --with-ngs-sdk-prefix=$PREFIX

make install

cd $SRC_DIR

./configure --prefix=$PREFIX --build-prefix=$PREFIX/share/ncbi/ --with-ngs-sdk-prefix=$PREFIX --with-ncbi-vdb-sources=$SRC_VDB --with-ncbi-vdb-build=$PREFIX/share/ncbi

make
make install
make tests
