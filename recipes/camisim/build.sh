#!/bin/bash

set -xe 

mkdir -p  $PREFIX/bin

cp *.py $PREFIX/bin/
cp -R scripts $PREFIX/bin/scripts
cp -R tools $PREFIX/bin/tools
cp -R defaults $PREFIX/bin/defaults


