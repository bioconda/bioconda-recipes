#!/bin/bash

#zlib headers for minimap
sed -i "8i CFLAGS+=-L$PREFIX/lib" lib/minimap2/Makefile
sed -i "9i INCLUDES+=-I$PREFIX/include" lib/minimap2/Makefile

#zlib headers for flye binaries
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

#dynamic flag is needed for backtrace printing, 
#but it seems it fails OSX build
sed -i 's/-rdynamic//' src/Makefile

python setup.py build
python setup.py install  --record record.txt.
