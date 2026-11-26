#!/bin/bash
set -euo pipefail

SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${SHARE}/model" "${SHARE}/scripts" "${PREFIX}/bin"

# Script, HMM classifier and its label map (panteraGA reads them from its own folder)
install -m 755 panteraGA "${SHARE}/panteraGA"
install -m 644 scripts/pantera_classify.R "${SHARE}/scripts/pantera_classify.R"
install -m 644 model/label_map.tsv "${SHARE}/model/label_map.tsv"

# HMM libraries from Zenodo -> model/hmm. conda-build may or may not strip the archive's top folder
# (pantera_hmm_v2/), so the library folder is located by its protein file.
PROT=$(find zenodo_hmm -path '*/prot/pantera_v5.cal.hmm.gz' -type f | head -n 1)
[ -n "${PROT}" ] || { echo "pantera_hmm_v2 library not found in zenodo_hmm" >&2; exit 1; }
cp -r "$(dirname "$(dirname "${PROT}")")" "${SHARE}/model/hmm"

# Relative symlink so the package stays relocatable
ln -s "../share/${PKG_NAME}-${PKG_VERSION}/panteraGA" "${PREFIX}/bin/panteraGA"
