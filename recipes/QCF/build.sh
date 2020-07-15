#!/bin/bash

cd $SRC_DIR
make
cp qcf ${PREFIX}/bin/qcf
chmod +x ${PREFIX}/bin/qcf
