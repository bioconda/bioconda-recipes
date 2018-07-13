#!/bin/bash
sed -i.bak 's/-rdynamic//' src/Makefile
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
python setup.py install  --record record.txt.
