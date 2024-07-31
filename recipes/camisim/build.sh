#!/bin/bash

set -xe 

mkdir -p  $PREFIX/bin

cp *.py $PREFIX/bin/
cp scripts $PREFIX/bin/scripts
cp tools $PREFIX/bin/tools
cp defaults $PREFIX/bin/defaults


