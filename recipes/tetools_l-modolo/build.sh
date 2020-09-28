#!/bin/bash

mkdir -p $PREFIX/bin
sed -i 's|#!/usr/bin/Rscript|#!/usr/bin/env Rscript|' TEdiff.R
EXEC='PingPong.py TEcount.py TEdiff.R UrQt pingpongpro/pingpongpro'
chmod +x $EXEC
cp $EXEC $PREFIX/bin/