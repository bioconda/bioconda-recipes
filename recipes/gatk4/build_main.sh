#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

#sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' gatk
chmod +x gatk
cp gatk ${PACKAGE_HOME}/gatk
cp gatk-*-local.jar $PACKAGE_HOME
# Does not install the spark jars, this is done in the `build_spark.sh`

ln -s $PACKAGE_HOME/gatk $PREFIX/bin
