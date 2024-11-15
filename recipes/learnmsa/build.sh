#!/bin/bash

cp $SRC_DIR/*.py ${PREFIX}/
chmod +x ${PREFIX}/*.py
sed -i.bak '1s|^|#!/usr/bin/env python3\n|' ${PREFIX}/learnMSA.py

ln -s ${PREFIX}/learnMSA.py ${PREFIX}/learnmsa

mkdir -p ${PREFIX}/learnMSA
cp -R $SRC_DIR/learnMSA/* ${PREFIX}/learnMSA/
chmod -R +x ${PREFIX}/learnMSA/