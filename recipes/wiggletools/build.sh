#!/bin/bash

LIBBIGWIG_VERSION=0.3.0
LIBBIGWIG_SHA256=221002fe249e8099009f0790f44bfe991e85cb23763cf5fc494e745c0160edc2

curl -L https://github.com/dpryan79/libBigWig/archive/${LIBBIGWIG_VERSION}.tar.gz \
	> libBigWig-${LIBBIGWIG_VERSION}.tar.gz

[[ $LIBBIGWIG_SHA256 == $(cat libBigWig-${LIBBIGWIG_VERSION}.tar.gz |shasum -a 256| cut -f1 -d ' ') ]] && echo "libBigWig Download success" || exit 1

mkdir -p libBigWig

tar xzf libBigWig-${LIBBIGWIG_VERSION}.tar.gz -C libBigWig

SRC_LIBBIGWIG=$SRC_DIR/libBigWig/libBigWig-${LIBBIGWIG_VERSION}


####
# build libBigWig
####

cd $SRC_LIBBIGWIG
export ROOT=$PREFIX
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
make install prefix=$PREFIX/
cp bigWig.h $PREFIX/include
cp -r libBigWig.a libBigWig.so $PREFIX/lib

####
# build wiggletools
####
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

echo "###########################################################"
echo $PREFIX
echo "###########################################################"
cd $SRC_DIR
mkdir -p lib
cp -r $PREFIX/include/* src
cp -r $PREFIX/lib/* lib/
cp $PREFIX/lib/libBigWig.a lib
make
cp -r lib/libwiggletools.a $PREFIX/lib
cp bin/wiggletools $PREFIX/bin
