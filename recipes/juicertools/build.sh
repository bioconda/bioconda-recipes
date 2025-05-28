#!/bin/sh
set -x -e

VERSION=${PKG_VERSION}

JUICERTOOLS_DIR=${PREFIX}/share/${PKG_NAME}

mkdir -p ${PREFIX}/bin
mkdir -p ${JUICERTOOLS_DIR}

cp "juicer_tools.${VERSION}.jar" ${JUICERTOOLS_DIR}/juicer_tools.jar
cp ${RECIPE_DIR}/juicer_tools.sh ${JUICERTOOLS_DIR}/juicer_tools

chmod +x ${JUICERTOOLS_DIR}/juicer_tools
ln -s ${JUICERTOOLS_DIR}/juicer_tools ${PREFIX}/bin
