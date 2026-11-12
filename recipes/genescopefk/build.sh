#!/usr/bin/env bash

R -e 'install.packages(".", repos=NULL, type="source")'

mkdir -p $PREFIX/bin
cp GeneScopeFK.R $PREFIX/bin/GeneScopeFK.R
chmod +x $PREFIX/bin/GeneScopeFK.R
