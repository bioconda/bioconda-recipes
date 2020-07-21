#! /bin/bash

#link in /bin, following bioconda rules
mkdir -p ${PREFIX}/bin
echo $SRC_DIR
echo `ls $SRC_DIR` 
cp $SRC_DIR/CATCh-1.0/CATCh_v1.run ${PREFIX}/bin

