#!/bin/sh
set -x -e

# Put craq in share
CRAQ_DIR=${PREFIX}/share/CRAQ
mkdir -p ${CRAQ_DIR}
cp -r * ${CRAQ_DIR}
chmod +x ${CRAQ_DIR}/bin/craq

# add link in bin
mkdir -p ${PREFIX}/bin
ln -s ${CRAQ_DIR}/bin/craq ${PREFIX}/bin/craq
