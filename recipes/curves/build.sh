#!/usr/bin/env bash

# Compile using make
make 

# Copy executable to environment bin directory. This folder is included in the path when the env is activated
mkdir -p $PREFIX/bin

chmod u+x Cur+
chmod u+x Canal
chmod u+x Canion
cp Cur+ Canal Canion $PREFIX/bin/

mkdir -p $PREFIX/.curvesplus
cp standard_b.lis $PREFIX/.curvesplus
cp standard_i.lis $PREFIX/.curvesplus
cp standard_s.lis $PREFIX/.curvesplus
