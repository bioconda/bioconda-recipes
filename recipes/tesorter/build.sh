#!/bin/sh
set -x -e

sh build_database.sh

TEsorter_DIR=${PREFIX}/share/TEsorter
mkdir -p ${PREFIX}/bin
mkdir -p ${TEsorter_DIR}
cp -r * ${TEsorter_DIR}

ln -s TEsorter.py ${PREFIX}/bin/TEsorter.py
