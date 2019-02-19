#!/bin/bash

#zlib headers for minimap
export C_INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"

#zlib headers for flye binaries
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

#dynamic flag is needed for backtrace printing, 
#but it seems it fails OSX build
sed -i.bak 's/-rdynamic//' src/Makefile

python setup.py build
python setup.py install  --record record.txt.
