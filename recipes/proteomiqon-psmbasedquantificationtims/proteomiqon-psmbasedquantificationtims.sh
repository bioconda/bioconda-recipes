#!/usr/bin/env bash

LD_LIBRARY_PATH=/usr/local/lib ldd .../SQLite.Interop.dll
exec dotnet "$CONDA_PREFIX/lib/dotnet/tools/PSMBasedQuantificationTIMs/ProteomIQon.PSMBasedQuantificationTIMs.dll" "$@"
