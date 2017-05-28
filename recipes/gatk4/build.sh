#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

SCRIPT_HASH=7332d10f1cd19a46f6f5b072be1031884f47b5a2
wget --no-check-certificate https://raw.githubusercontent.com/broadinstitute/gatk/$SCRIPT_HASH/gatk-launch
wget --no-check-certificate https://raw.githubusercontent.com/broadinstitute/gatk/$SCRIPT_HASH/settings.gradle
sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' gatk-launch
chmod +x gatk-launch
cp gatk-launch $PACKAGE_HOME
cp settings.gradle $PACKAGE_HOME
cp gatk-*.jar $PACKAGE_HOME

ln -s $PACKAGE_HOME/gatk-launch $PREFIX/bin
