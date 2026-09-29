#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

cp vicmag.py "${PREFIX}/bin/vicmag"

if ! head -n 1 "${PREFIX}/bin/vicmag" | grep -q "^#!"; then
    tmpfile=$(mktemp)
    echo "#!/usr/bin/env python" > "${tmpfile}"
    cat "${PREFIX}/bin/vicmag" >> "${tmpfile}"
    mv "${tmpfile}" "${PREFIX}/bin/vicmag"
fi

chmod +x "${PREFIX}/bin/vicmag"
