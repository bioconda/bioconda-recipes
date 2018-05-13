#!/bin/bash
# Copied from https://github.com/bioconda/bioconda-recipes/blob/master/recipes/picard/build.sh
set -eu -o pipefail
BIN_NAME="break-point-inspector"
JAR_NAME="break-point-inspector-1.5-jar-with-dependencies.jar"

TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
[ -d "${TGT}" ] || mkdir -p "${TGT}"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
# Do not install Linux specific x86-acceleration libraries
if [ "$(uname)" == "Darwin" ]; then
    rm -f libIntel*.so
fi
cp -rvp . "${TGT}"

cp ${RECIPE_DIR}/${BIN_NAME}.sh ${TGT}/${BIN_NAME}
ln -s ${TGT}/${BIN_NAME} ${PREFIX}/bin
chmod 0755 "${PREFIX}/bin/${BIN_NAME}"