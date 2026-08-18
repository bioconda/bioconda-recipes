#!/usr/bin/env bash

export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
exec dotnet "$CONDA_PREFIX/lib/dotnet/tools/PSMBasedQuantificationTIMs/ProteomIQon.PSMBasedQuantificationTIMs.dll" "$@"
