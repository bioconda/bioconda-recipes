#!/bin/bash
export JAVA_HOME=$PREFIX

TGT=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${TGT}
mkdir -p ${PREFIX}/bin

cp -R . ${TGT}
ln -s ${TGT}/mixcr  ${PREFIX}/bin/mixcr
