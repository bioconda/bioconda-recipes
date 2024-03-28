#!/usr/bin/env bash

R -e 'install.packages(".", repos=NULL, type="source")'

mkdir -p $PREFIX/bin
cp genomescope.R $PREFIX/bin/genomescope.R
chmod +x $PREFIX/bin/genomescope.R

ln -s genomescope.R $PREFIX/bin/genomescope2
