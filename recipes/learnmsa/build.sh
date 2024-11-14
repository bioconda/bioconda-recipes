#!/bin/bash

cp $SRC_DIR/*.py ${PREFIX}/
chmod +x ${PREFIX}/*.py

mkdir -p ${PREFIX}/learnMSA
cp -R $SRC_DIR/learnMSA/* ${PREFIX}/learnMSA/
chmod -R +x ${PREFIX}/learnMSA/
cp $SRC_DIR/*.py ${PREFIX}/
