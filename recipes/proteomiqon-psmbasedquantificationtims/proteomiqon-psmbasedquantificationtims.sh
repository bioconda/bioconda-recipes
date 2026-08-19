#!/usr/bin/env bash

PREFIX="${CONDA_PREFIX:-/usr/local}"

export LD_LIBRARY_PATH="${PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

exec "${PREFIX}/lib/dotnet/dotnet" \
    "${PREFIX}/lib/dotnet/tools/PSMBasedQuantificationTIMs/ProteomIQon.PSMBasedQuantificationTIMs.dll" "$@"
