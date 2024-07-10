#!/bin/bash

mkdir -p $PREFIX/lib/R/library/pathphynder
cp -r R/ data/ $PREFIX/lib/R/library/pathphynder
sed -i "s#^packpwd<-.*\+\$#packpwd<-'$PREFIX/lib/R/library/pathphynder/R'#g" pathPhynder.R
cp pathPhynder.R $PREFIX/bin/pathPhynder
