#!/bin/sh

APPROOT=$PREFIX/opt/$PKG_NAME-$PKG_VERSION


mkdir -p $APPROOT
mkdir -p ${PREFIX}/bin
# cp -r ./* $APPROOT
cp -r dqc $APPROOT/dqc
cp -r docs $APPROOT/docs
cp dfast_qc $APPROOT
cp dqc_admin_tools.py $APPROOT
cp initial_setup.sh $APPROOT


cd ${PREFIX}/bin
ln -s ${APPROOT}/dfast_qc
ln -s ${APPROOT}/dqc_admin_tools.py

