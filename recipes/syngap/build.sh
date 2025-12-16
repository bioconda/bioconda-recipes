#!/bin/bash

mkdir -p ${PREFIX}/bin

cp -rf ${SRC_DIR}/bin ${PREFIX}/bin
cp -rf ${SRC_DIR}/scripts ${PREFIX}/bin
cp -f ${SRC_DIR}/*.py ${PREFIX}/bin
