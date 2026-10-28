#!/usr/bin/env bash
set -euo pipefail
# the code tree is installed read-only under share/; runs live in project dirs
dest="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${dest}" "${PREFIX}/bin"
cp -r bin config envs profiles scripts workflow input VERSION LICENSE README.md "${dest}/"
chmod +x "${dest}/bin/phagefactor" "${dest}/scripts/setup/"*.sh
ln -s "../share/${PKG_NAME}-${PKG_VERSION}/bin/phagefactor" "${PREFIX}/bin/phagefactor"   # relative: the prefix is relocated
