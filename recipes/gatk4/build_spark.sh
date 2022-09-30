#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

#Runtime script will be installed using the `build_main.sh` already, so we don't have to modify this anymore.
#Only installs the SPARK JARs, everything else is installed using the `build_main.sh` already.
cp gatk-*-spark.jar $PACKAGE_HOME
