#!/bin/bash

NGS_SDK_VERSION=1.3.0
NCBI_VDB_VERSION=2.8.1-3

NGS_SDK_SHA256=803c650a6de5bb38231d9ced7587f3ab788b415cac04b0ef4152546b18713ef2
NGS_VDB_SHA256=17069e6d6920312c08fffd2b5bb89cba068059425349c4da843139a57df4d91f


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
