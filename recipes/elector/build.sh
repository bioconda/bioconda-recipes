#!/bin/bash

set -x

mkdir -p $PREFIX/bin/
# build and install binary tools
cd src/simulator
make CC="${CXX}"
cp simulator $PREFIX/bin/

cd ../poa-graph
make CC="${CC}" poa
cp poa $PREFIX/bin/

cd ../utils
make CC="${CXX}"
cp fq2fa $PREFIX/bin/

cd ../split
make CC="${CXX}"
cp masterSplitter $PREFIX/bin/
cp Donatello $PREFIX/bin/
cd ../..

# setup and install python script
mkdir -p $PREFIX/share/elector/
cp src/poa-graph/blosum80.mat $PREFIX/share/elector/

$PYTHON setup.py install
