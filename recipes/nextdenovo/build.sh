#!/bin/bash
set -x

SHARE_DIR=${PREFIX}/share/${PKG_NAME}-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p ${PREFIX}/bin ${SHARE_DIR}
cp -r ./* ${SHARE_DIR}
chmod a+x ${SHARE_DIR}/nextDenovo
ln -s ${SHARE_DIR}/nextDenovo ${PREFIX}/bin/nextDenovo
export PYTHONPATH=${PYTHONPATH}:${SHARE_DIR}/lib
