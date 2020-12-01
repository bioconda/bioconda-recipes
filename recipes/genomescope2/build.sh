#!/usr/bin/env bash

R -e 'install.packages(".", repos=NULL, type="source")'

mkdir -p $PREFIX/bin
ln -s genomescope.R $PREFIX/genomescope2
