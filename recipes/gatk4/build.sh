#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

SCRIPT_HASH=b6fbcf5b973d42cc3ffb660bf0b9a4c52f87d1e8
GIT_URL=https://raw.githubusercontent.com/broadinstitute/gatk
wget --no-check-certificate $GIT_URL/$SCRIPT_HASH/gatk-launch
wget --no-check-certificate $GIT_URL/$SCRIPT_HASH/settings.gradle
sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' gatk-launch
chmod +x gatk-launch
cp gatk-launch $PACKAGE_HOME
cp settings.gradle $PACKAGE_HOME
cp gatk-*.jar $PACKAGE_HOME

ln -s $PACKAGE_HOME/gatk-launch $PREFIX/bin
