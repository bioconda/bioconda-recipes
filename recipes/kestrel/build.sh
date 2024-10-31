#!/bin/bash
set -euo pipefail

kestrel="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${kestrel}" || exit 1
cp -r ./* "${kestrel}" || exit 1
chmod +x "${kestrel}/kestrel" || exit 1
mkdir -p "${PREFIX}/bin" || exit 1
if [[ -L "${PREFIX}/bin/kestrel" ]]; then
    rm "${PREFIX}/bin/kestrel"
fi
if [[ ! -f "${kestrel}/kestrel" ]]; then
    echo "Error: Target file ${kestrel}/kestrel does not exist"
    exit 1
fi
ln -s "${kestrel}/kestrel" "${PREFIX}/bin/kestrel" || exit 1

