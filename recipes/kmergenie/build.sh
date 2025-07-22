#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include"
export LC_ALL=C

mkdir -p $PREFIX/bin

sed -i.bak 's/print sys.hexversion>=0x02050000/print(sys.hexversion>=0x02050000)/' makefile

make

sed -i.bak 's/third_party\.//g' scripts/*
sed -i.bak 's/third_party\.//g' kmergenie
sed -i.bak 's/scripts\///g' kmergenie

cp scripts/* $PREFIX/bin
cp third_party/* $PREFIX/bin
cp specialk $PREFIX/bin
cp kmergenie $PREFIX/bin
cp wrapper.py $PREFIX/bin

# Fix KmerGenie directory structure expectations
mkdir -p $PREFIX/bin/scripts
mkdir -p $PREFIX/bin/ntCard

# Create symlinks for expected paths
ln -sf $PREFIX/bin/decide $PREFIX/bin/scripts/decide
ln -sf $PREFIX/bin/ntcard $PREFIX/bin/ntCard/ntcard

# Download and install readfq Python module
mkdir -p $PREFIX/lib/python2.7/site-packages
wget -q -O $PREFIX/lib/python2.7/site-packages/readfq.py \
    https://raw.githubusercontent.com/lh3/readfq/master/readfq.py

# Make readfq.py executable
chmod +x $PREFIX/lib/python2.7/site-packages/readfq.py