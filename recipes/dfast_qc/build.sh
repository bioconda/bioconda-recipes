#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION


mkdir -p $APPROOT
mkdir -p ${PREFIX}/bin
cp -r ./* $APPROOT

ln -s ${APPROOT}/dfast_qc ${PREFIX}/bin/dfast_qc
ln -s ${APPROOT}/dqc_admin_tools.py ${PREFIX}/bin/dqc_admin_tools.py

