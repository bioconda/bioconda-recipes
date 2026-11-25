#!/usr/bin/env bash
set -euo pipefail

export FOCALOOP_PORTABLE_ISA=1
make install-native PREFIX="${PREFIX}" PYTHON="${PYTHON}"
if [[ "$(uname -s)" == "Darwin" ]]; then
    for dylib in "${PREFIX}"/share/focaloop/native_cache/*.dylib; do
        if [[ -f "${dylib}" ]]; then
            "${INSTALL_NAME_TOOL:-install_name_tool}" -id "${dylib}" "${dylib}"
        fi
    done
fi
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
