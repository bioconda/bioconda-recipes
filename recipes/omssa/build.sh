#!/bin/bash

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-$PKG_VERSION-$PKG_BUILDNUM"

mkdir -p "${SHARE_DIR}"
cp -r ./* "${SHARE_DIR}"

mkdir "${PREFIX}/bin"

ln -s "${SHARE_DIR}/omssacl" "${PREFIX}/bin/omssacl"
ln -s "${SHARE_DIR}/omssa2pepXML" "${PREFIX}/bin/omssa2pepXML"
ln -s "${SHARE_DIR}/omssamerge" "${PREFIX}/bin/omssamerge"

# clean up
rm ${SHARE_DIR}/*.sh ${SHARE_DIR}/*.yaml
