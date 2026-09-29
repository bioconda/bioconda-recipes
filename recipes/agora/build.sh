#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/share/${PKG_NAME}"
cp -r . "${PREFIX}/share/${PKG_NAME}/"

mkdir -p "${PREFIX}/bin"
for script in src/*.py; do
    script_name=$(basename "${script}")
    wrapper="${PREFIX}/bin/${script_name}"
    printf '#!/usr/bin/env bash\n_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"\nPYTHONPATH="${_dir}/../share/agora/src${PYTHONPATH:+:${PYTHONPATH}}" exec python "${_dir}/../share/agora/src/%s" "$@"\n' \
        "${script_name}" > "${wrapper}"
    chmod +x "${wrapper}"
done
