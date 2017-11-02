#!/bin/bash

make

ls *.pl | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g' 

mkdir -p $PREFIX/bin
cp velvetg $PREFIX/bin
cp velveth $PREFIX/bin
cp *.pl $PREFIX/bin