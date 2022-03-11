#!/bin/bash -e
set -x
chmod a+x ${SRC_DIR}/*.py
ln -s ${SRC_DIR}/*.py ${PREFIX}/bin
