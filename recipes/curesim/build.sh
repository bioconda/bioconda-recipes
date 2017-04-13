#!/bin/bash -u -f -e -o pipefail

STRANGEDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $STRANGEDIR

cp CuReSim1.3/CuReSim.jar $STRANGEDIR
cp curesim $STRANGEDIR

(cd ${PREFIX}/bin && ln -s ${STRANGEDIR}/curesim)

