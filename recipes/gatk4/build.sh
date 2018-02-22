#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' gatk
chmod +x gatk
cp gatk ${PACKAGE_HOME}/gatk-launch
cp gatk-*-local.jar $PACKAGE_HOME
# Does not yet install spark jar to save space.
# cp gatk-*-spark.jar $PACKAGE_HOME

ln -s $PACKAGE_HOME/gatk-launch $PREFIX/bin
