#!/bin/bash
ZTGT=${PREFIX}/share/sis.zip
TGT=${PREFIX}/share/sis
unzip $ZTGT
for file in `ls -1 ${TGT}/*.py`
	do ln -s ${TGT}/$file ${PREFIX}/bin/$file
done
