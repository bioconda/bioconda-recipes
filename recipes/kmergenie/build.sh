#!/bin/sh
set -x -e

#export GCC=${PREFIX}/bin/gcc
#export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include"
export LC_ALL=C

mkdir -p $PREFIX/bin

sed -i.bak 's/print sys.hexversion>=0x02050000/print(sys.hexversion>=0x02050000)/' makefile
rm *.bak

make

sed -i.bak 's/third_party/kmergenie/g' scripts/*
sed -i.bak 's/third_party/kmergenie/g' kmergenie

rm scripts/*.bak
rm kmergenie.bak

cp scripts/* $PREFIX/bin
cp specialk $PREFIX/bin

mkdir -p python-build/scripts
cp kmergenie python-build/scripts
cp wrapper.py python-build/scripts
cp -rf third_party python-build/kmergenie

cd python-build

cp $RECIPE_DIR/setup.py ./

python setup.py build
python setup.py install
