#!/usr/bin/env bash
set -euxo pipefail
DEST_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${DEST_DIR}"
SOURCE_SUBDIR="${SRC_DIR}/${PKG_NAME}"
# copy in share
cp -r "${SOURCE_SUBDIR}"/* "${DEST_DIR}/"
chmod -R a+rX "${DEST_DIR}"
# symlink them
mkdir -p "${PREFIX}/bin"
for exe in EXCAVATORDataAnalysis.pl EXCAVATORDataPrepare.pl TargetPerla.pl; do
  # Make the source files executable *before* linking
  chmod +x "${DEST_DIR}/${exe}"
  ln -s "${DEST_DIR}/${exe}" "${PREFIX}/bin/${exe}"
done
