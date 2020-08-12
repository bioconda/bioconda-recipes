#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION


mkdir -p $APPROOT
mkdir -p ${PREFIX}/bin
cp -r ./* $APPROOT

cd ${PREFIX}/bin
ln -s ${APPROOT}/dfast_qc
ln -s ${APPROOT}/dqc_admin_tools.py

