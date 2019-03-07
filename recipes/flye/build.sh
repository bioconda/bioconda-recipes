#!/bin/bash

#zlib headers for minimap
sed -i.bak "8iCFLAGS+=-L$PREFIX/lib" lib/minimap2/Makefile
sed -i.bak "9iINCLUDES+=-I$PREFIX/include" lib/minimap2/Makefile

#zlib headers for flye binaries
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

#dynamic flag is needed for backtrace printing, 
#but it seems it fails OSX build
sed -i.bak 's/-rdynamic//' src/Makefile

python setup.py build
python setup.py install  --record record.txt.
