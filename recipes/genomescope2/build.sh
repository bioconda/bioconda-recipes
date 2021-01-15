#!/usr/bin/env bash

R -e 'install.packages(".", repos=NULL, type="source")'

mkdir -p $PREFIX/bin
cp genomescope.R $PREFIX/bin/genomescope2
chmod +x $PREFIX/bin/genomescope2
