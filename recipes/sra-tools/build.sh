#!/bin/bash

NGS_SDK_VERSION=1.2.5
NCBI_VDB_VERSION=2.7.0

curl -L https://github.com/ncbi/ngs/archive/${NGS_SDK_VERSION}.tar.gz \
	> ngs-sdk-${NGS_SDK_VERSION}.tar.gz
curl -L https://github.com/ncbi/ncbi-vdb/archive/${NCBI_VDB_VERSION}.tar.gz \
	> ncbi-vdb-${NCBI_VDB_VERSION}.tar.gz

mkdir -p ngs-sdk
mkdir -p ncbi-vdb

tar xzf ngs-sdk-${NGS_SDK_VERSION}.tar.gz -C ngs-sdk
tar xzf ncbi-vdb-${NCBI_VDB_VERSION}.tar.gz -C ncbi-vdb

SRC_SDK=$SRC_DIR/ngs-sdk/ngs-${NGS_SDK_VERSION}
SRC_VDB=$SRC_DIR/ncbi-vdb/ncbi-vdb-${NCBI_VDB_VERSION}

####
# build ngs-sdk
####

cd $SRC_SDK
# First configure fails
# See: https://github.com/ncbi/ngs/issues/1
./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi
make -C ngs-sdk

./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi
make -C ngs-sdk install

####
# build ncbi-vdb
####

cd $SRC_VDB
./configure --prefix=$PREFIX/ \
	    --build-prefix=$PREFIX/share/ncbi \
            --with-ngs-sdk-prefix=$PREFIX
make install

####
# build sra-tools
####

cd $SRC_DIR
./configure --prefix=$PREFIX \
	--build-prefix=$PREFIX/share/ncbi/ \
	--with-ncbi-vdb-sources=$SRC_VDB \
	--with-ncbi-vdb-build=$PREFIX/share/ncbi/ncbi-vdb \
	--with-ngs-sdk-prefix=$PREFIX

make install
