#!/bin/bash

TGT=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${TGT}
mkdir -p ${PREFIX}/bin
cp -R bin ${TGT}
cp -R lib ${TGT}
for file in `ls -1 ${TGT}/bin`
	do ln -s ${TGT}/bin/$file ${PREFIX}/bin/$file
done
