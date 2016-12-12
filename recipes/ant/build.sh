#!/bin/bash
export JAVA_HOME=$PREFIX

TGT=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${TGT}
mkdir -p ${PREFIX}/bin
./build.sh
cp -R dist/bin ${TGT}
cp -R dist/lib ${TGT}
for file in `ls -1 ${TGT}/bin`
	do ln -s ${TGT}/bin/$file ${PREFIX}/bin/$file
done
