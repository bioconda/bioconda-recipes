#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/data

cp markers/markers.dna $PREFIX/data
cp markers/markers.protein $PREFIX/data
cp markers/tid2name.tab $PREFIX/data

sed -i.bak "s|Bin/markers|Bin/../data|g" installMetaphyler.pl
sed -i.bak "s|Bin/markers|Bin/../data|g" runMetaphyler.pl

ls *.pl | xargs sed -i.bak -e '1 s|^.*$|#!/usr/bin/env perl|g'
cp *.pl $PREFIX/bin
cp combine $PREFIX/bin
cp simuReads $PREFIX/bin
cp metaphylerTrain $PREFIX/bin
cp metaphylerClassify $PREFIX/bin
cp taxprof $PREFIX/bin
