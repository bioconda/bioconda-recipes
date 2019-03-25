#!/bin/bash

echo "###################"
echo "#      DEBUG      #"
echo "###################"

echo ""
echo "Current directory:" $(pwd)
echo ""
echo "Contents:"
echo ""
ls -l
echo ""

rm -rf SeqLib
git clone --recursive https://github.com/walaj/SeqLib
cd SeqLib
git checkout f7a89a127409a3f52fdf725fa74e5438c68e48fb
cd ..

echo "##################"
echo "#   MORE DEBUG   #"
echo "##################"

echo ""
ls -l SeqLib
echo ""

echo "##################"
echo "#   DEBUG DONE   #"
echo "##################"

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

./configure --prefix=$PREFIX
make
make install
