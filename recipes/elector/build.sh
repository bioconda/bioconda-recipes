#!/bin/bash

set -x

mkdir -p $PREFIX/bin/
# build and install binary tools
cd src/simulator
sed -i "s#CC=g++#CC=${CXX}#" makefile
make
cp simulator $PREFIX/bin/

cd ../poa-graph
sed -i "s#CC = gcc#CC=${CC}#" Makefile
make poa
cp poa $PREFIX/bin/

cd ../utils
sed -i "s#CC=g++#CC=${CXX}#" makefile
make
cp fq2fa $PREFIX/bin/

cd ../split
sed -i "s#CC=g++#CC=${CXX}#" makefile
make
cp masterSplitter $PREFIX/bin/
cp Donatello $PREFIX/bin/
cd ../..

# setup and install python script
mkdir -p $PREFIX/share/elector/
cp src/poa-graph/blosum80.mat $PREFIX/share/elector/

sed -i "s#os.path.dirname(os.path.realpath(__file__))+\"/../bin/\"#${PREFIX}/bin/#" elector/utils.py
sed -i "s#os.path.dirname(os.path.realpath(__file__))+\"/../src/poa-graph/\"#${PREFIX}/share/elector/#" elector/utils.py

$PREFIX/bin/pip install .
