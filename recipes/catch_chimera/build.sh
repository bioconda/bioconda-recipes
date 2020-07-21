#! /bin/bash

#link in /bin, following bioconda rules
mkdir -p ${PREFIX}/bin
ln -s $SRC_DIR/CATCh.run ${PREFIX}/bin/CATCh.run

