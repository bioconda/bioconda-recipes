#!/bin/bash

NGS_SDK_VERSION=2.9.0
NCBI_VDB_VERSION=2.9.0-1

NGS_SDK_SHA256=7e4f9e4490309b6fb33ec9370e5202ad446b10b75c323ba8226c29ca364a0857
NGS_VDB_SHA256=b4099e2fc3349eaf487219fbe798b22124949c89ffa1e7e6fbaa73a5178c8aff


curl -L https://github.com/ncbi/ngs/archive/${NGS_SDK_VERSION}.tar.gz \
	> ngs-sdk-${NGS_SDK_VERSION}.tar.gz
curl -L https://github.com/ncbi/ncbi-vdb/archive/${NCBI_VDB_VERSION}.tar.gz \
	> ncbi-vdb-${NCBI_VDB_VERSION}.tar.gz

[[ $NGS_SDK_SHA256 == $(cat ngs-sdk-${NGS_SDK_VERSION}.tar.gz |shasum -a 256| cut -f1 -d ' ') ]] && echo "NGS SDK Download success" || exit 1
[[ $NGS_VDB_SHA256 == $(cat ncbi-vdb-${NCBI_VDB_VERSION}.tar.gz |shasum -a 256| cut -f1 -d ' ') ]] && echo "NCBI VDB Download success" || exit 1

mkdir -p ngs-sdk
mkdir -p ncbi-vdb

tar xzf ngs-sdk-${NGS_SDK_VERSION}.tar.gz -C ngs-sdk
tar xzf ncbi-vdb-${NCBI_VDB_VERSION}.tar.gz -C ncbi-vdb

SRC_SDK=$SRC_DIR/ngs-sdk/ngs-${NGS_SDK_VERSION}
SRC_VDB=$SRC_DIR/ncbi-vdb/ncbi-vdb-${NCBI_VDB_VERSION}


if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

####
# build ngs-sdk
####

cd $SRC_SDK
# First configure fails
# See: https://github.com/ncbi/ngs/issues/1
export ROOT=$PREFIX
mkdir -p $PREFIX/usr/include
./configure --prefix=$PREFIX/ --build=$PREFIX/share/ncbi
make -C ngs-sdk

./configure --prefix=$PREFIX/ --build=$PREFIX/share/ncbi
make -C ngs-sdk install

####
# build ncbi-vdb
####

cd $SRC_VDB
./configure --prefix=$PREFIX/ \
	    --build=$PREFIX/share/ncbi \
            --with-ngs-sdk-prefix=$PREFIX
make install

####
# build sra-tools
####

cd $SRC_DIR
export VDB_SRCDIR=$SRC_VDB
./configure --prefix=$PREFIX \
	--build=$PREFIX/share/ncbi/ \
	--with-ncbi-vdb-sources=$SRC_VDB \
	--with-ncbi-vdb-build=$PREFIX/share/ncbi \
	--with-ngs-sdk-prefix=$PREFIX

make install
