#!/usr/bin/env bash

R -e 'install.packages(".", repos=NULL, type="source")'

mkdir -p $PREFIX/bin
cp genomescope.R $PREFIX/genomescope2
chmod +x $PREFIX/genomescope2
