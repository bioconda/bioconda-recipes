#!/bin/bash

# make from src directory then add bin and scripts for installation
mkdir -p $PREFIX/bin


cd src
make all
cd ..

#cp  scripts/* bin/.
cp scripts/* $PREFIX/bin/.
cp bin/* $PREFIX/bin/.

