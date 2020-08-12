#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION


mkdir -p $APPROOT
mkdir -p ${PREFIX}/bin
cp -r ./* $APPROOT

ls ./ # for debug
ls $APPROOT # for debug

cd ${PREFIX}/bin
ln -s ${APPROOT}/dfast_qc
ln -s ${APPROOT}/dqc_admin_tools.py

ls .  # for debug
