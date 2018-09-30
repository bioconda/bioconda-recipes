#!/bin/bash

svn checkout https://github.com/seqan/seqan/trunk/include >/dev/null 2>&1
make binstrings 
cp binstrings $PREFIX/bin
rm -r -f include
