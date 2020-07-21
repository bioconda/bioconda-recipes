#! /bin/bash

#link in /bin, following bioconda rules
mkdir -p ${PREFIX}/bin
echo `echo $SRC_DIR` 
echo `ls $SRC_DIR` 
echo `ls ${PREFIX}/bin`
echo `ls -lh $SRC_DIR/CATCh_v1.run`
cp $SRC_DIR/CATCh_v1.run ${PREFIX}/bin

