#!/bin/bash
set -euo pipefail

SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${SHARE}/model" "${PREFIX}/bin"

# Script
install -m 755 panteraGA "${SHARE}/panteraGA"

# BLAST protein library (already indexed in the repository)
cp -r libs "${SHARE}/"

# Model: small text files from the repo, real model from Zenodo
cp model/typesnames model/featurenames "${SHARE}/model/"
# conda-build unpacks a .tar.gz itself; a plain .gz may arrive still compressed.
MODEL=$(find zenodo_model -name 'xgbmodel.ubj*' -type f | head -n 1)
case "${MODEL}" in
  *.gz) gunzip -c "${MODEL}" > "${SHARE}/model/xgbmodel.ubj" ;;
  *)    cp "${MODEL}" "${SHARE}/model/xgbmodel.ubj" ;;
esac

# Relative symlink so the package stays relocatable
ln -s "../share/${PKG_NAME}-${PKG_VERSION}/panteraGA" "${PREFIX}/bin/panteraGA"
