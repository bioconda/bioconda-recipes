#!/bin/bash

set -x

mkdir -p $PREFIX/bin/
# build and install binary tools
cd src/simulator
make
cp simulator $PREFIX/bin/

cd ../poa-graph
make poa CXXFLAGS="$CXXFLAGS -fcommon"
cp poa $PREFIX/bin/

cd ../utils
make
cp fq2fa $PREFIX/bin/

cd ../split
make
cp masterSplitter $PREFIX/bin/
cp Donatello $PREFIX/bin/
cd ../..

# setup and install python script
mkdir -p $PREFIX/share/elector/
cp src/poa-graph/blosum80.mat $PREFIX/share/elector/

"${PYTHON}" -m pip install . --no-deps -vv
