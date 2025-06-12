#!/bin/bash

set -euo pipefail

kestrel="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"

mkdir -p "${kestrel}"
cp -r ./* "${kestrel}"
chmod +x "${kestrel}/kestrel"
mkdir -p "${PREFIX}/bin"

if [[ -L "${PREFIX}/bin/kestrel" ]]; then
    echo "Error: File ${PREFIX}/bin/kestrel already exists"
    exit 1
fi

if [[ ! -f "${kestrel}/kestrel" ]]; then
    echo "Error: Target file ${kestrel}/kestrel does not exist"
    exit 1
fi
ln -s "${kestrel}/kestrel" "${PREFIX}/bin/kestrel" || exit 1
