#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

#export PYTHONPATH=$PYTHONPATH:$PREFIX/lib/python3.6/site-packages/
#sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' gatk
# pip install --ignore-installed numpy==1.17.5
# pip install scipy==1.0.0
# pip install pymc3==3.1
# pip install Theano==1.0.4
# pip install PyVCF==0.6.8

chmod +x gatk
cp gatk ${PACKAGE_HOME}/gatk
cp gatk-*-local.jar $PACKAGE_HOME

unzip gatkPythonPackageArchive.zip -d gatkPythonPackageArchive
cd gatkPythonPackageArchive
python setup.py install

# Does not install the spark jars, this is done in the `build_spark.sh`
ln -s $PACKAGE_HOME/gatk $PREFIX/bin
