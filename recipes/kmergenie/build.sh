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

make

mkdir -p python-build/
cp kmergenie python-build/
cp specialk python-build/
cp readfq.py python-build/
cp setup.py python-build/
cp README python-build/
cp makefile python-build/
cp main.cpp python-build/
cp CHANGELOG python-build/
cp -rf scripts/ python-build/
cp -rf third_party/ python-build/
cp -rf ntCard/ python-build/

cd python-build

python setup.py build
python setup.py install

