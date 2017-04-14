#!/bin/bash

STRANGEDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $STRANGEDIR

w=${STRANGEDIR}/curesim
cp CuReSim.jar $STRANGEDIR

cat /dev/null > $w
chmod +x $w
echo '#! /usr/bin/env bash' >> $w
echo 'java -jar $(dirname "$0")/CuReSim.jar $@' >> $w

(cd ${PREFIX}/bin && ln -s $w)
