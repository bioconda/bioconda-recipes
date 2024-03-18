#!/bin/bash
set -x
mkdir -p $PREFIX/bin

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include

#cp /root/v18.17.0.tar.gz .
#NOTE:Please prepare this "v18.17.0.tar.gz" package,Copy it to this directory,Otherwise,you can execute the following command to download this "v18.17.0.tar.gz" package
wget https://github.com/nodejs/node/archive/refs/tags/v18.17.0.tar.gz --no-ch
tar xf v18.17.0.tar.gz
cd node-18.17.0
./configure
make -j

cd -
sed -i "2c NODE_SRC=node-18.17.0" Makefile
sed -i "5s%LIB_LINUX=%LIB_LINUX=-L${PREFIX}/lib %g" Makefile
make
cp k8 $PREFIX/bin/k8
