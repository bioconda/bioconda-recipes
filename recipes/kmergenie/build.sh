#!/bin/sh
set -x -e

export GCC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p $PREFIX/bin

sed -i 's/print sys.hexversion>=0x02050000/print(sys.hexversion>=0x02050000)/' makefile

make

sed -i 's/third_party/kmergenie/g' scripts/*
sed -i 's/third_party/kmergenie/g' kmergenie

cp scripts/* $PREFIX/bin
cp specialk $PREFIX/bin

mkdir -p python-build/scripts
cp kmergenie python-build/scripts
cp wrapper.py python-build/scripts
cp -rf third_party python-build/kmergenie


cd python-build

echo "GREPPING FOR THIRD PARTY"
grep -nri 'third_party' *

cp $RECIPE_DIR/setup.py ./

python setup.py build
python setup.py install
