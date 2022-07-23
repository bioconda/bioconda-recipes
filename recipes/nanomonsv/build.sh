#!/bin/bash
set -x

"${PYTHON}" -m pip install --no-deps --ignore-installed -vv .
wget -q https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library/archive/v1.1.tar.gz
tar zxvf v1.1.tar.gz
cd Complete-Striped-Smith-Waterman-Library-1.1/src
${CC} -Wall -O3 -pipe -fPIC -shared -rdynamic -o libssw.so ssw.c ssw.h
mv libssw.so ${PREFIX}/lib/
