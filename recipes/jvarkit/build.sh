#! /usr/bin/env bash

export LC_ALL=en_US.UTF-8

# compile jars uising condaforge's gradle
gradle jvarkit


# setup directories
TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
[ -d "${TGT}" ] || mkdir -p "${TGT}"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

# jars
cp -p dist/*.jar "${TGT}"

# wrapper(s)
cp "${RECIPE_DIR}/${PKG_NAME}.sh" "${TGT}/${PKG_NAME}"
chmod 0755 "${TGT}/${PKG_NAME}"
# NOTE on older mac osx, use coreutils for realpath
ln -s "$(realpath --relative-to "${PREFIX}/bin" "${TGT}/${PKG_NAME}")" "${PREFIX}/bin/${PKG_NAME}"
