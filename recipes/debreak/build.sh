#!/bin/bash


mkdir -p $PREFIX/bin


chmod +x bsalign
cp bsalign $PREFIX/bin
chmod +x debreak
cp debreak *.py $PREFIX/bin
