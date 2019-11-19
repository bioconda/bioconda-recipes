#!/bin/bash

mkdir build && cd build
cmake ..
make

cd ..

echo "#################"
echo "##### DEBUG #####"
echo "#################"

echo ""

find .

echo ""

# cp ../bin/bayesTyper ${PREFIX}/bin
# cp ../bin/bayesTyperTools ${PREFIX}/bin
