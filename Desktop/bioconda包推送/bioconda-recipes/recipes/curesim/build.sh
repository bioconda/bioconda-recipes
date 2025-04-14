#!/bin/bash

STRANGEDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $STRANGEDIR

w=${STRANGEDIR}/curesim
cp CuReSim.jar $STRANGEDIR

cat /dev/null > $w
chmod +x $w
echo '#! /usr/bin/env bash' >> $w
echo 'd=$(dirname "$(realpath "$0")")' >> $w
echo 'java -jar ${d}/CuReSim.jar "$@"' >> $w

(cd ${PREFIX}/bin && ln -s $w)
