#!/bin/bash

# compile library
mkdir -p $PREFIX/lib/R/library/e1071FuzzVec
R CMD INSTALL --build e1071FuzzVec_Installation
cp -r e1071FuzzVec_Installation/* $PREFIX/lib/R/library/e1071FuzzVec/

# move all files to outdir and link into it by bin executor
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/$PKG_NAME
echo "sed"
# substituting paths for testing
cp run_app.sh run_vsclust_app.sh
sed -i "1 a setwd(\"\$CONDA_PREFIX/share/$PKG_NAME\")" run_vsclust_app.sh
sed -i "s=ProtExample.csv=\$CONDA_PREFIX/share/${PKG_NAME}/ProtExample.csv=" vsclust.yml
cat vsclust.yml
echo "copy"
cp *.R $PREFIX/share/$PKG_NAME
cp ProtExample.csv $PREFIX/share/$PKG_NAME
cp vsclust.yml $PREFIX/share/$PKG_NAME  
cp runVSClust.R $PREFIX/bin
cp run_vsclust_app.sh $PREFIX/bin
chmod a+x $PREFIX/bin/runVSClust.R
chmod a+x $PREFIX/bin/run_vsclust_app.sh
echo "finished build"
