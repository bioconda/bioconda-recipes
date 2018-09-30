#!/bin/bash

svn checkout https://github.com/seqan/seqan/trunk/include >/dev/null 2>&1
make diprofile 
cp diprofile $PREFIX/bin
rm -r -f include
