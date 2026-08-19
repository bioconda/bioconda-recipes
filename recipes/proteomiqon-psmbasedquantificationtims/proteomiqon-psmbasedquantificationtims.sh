#!/usr/bin/env bash

exec "${PREFIX}/lib/dotnet/dotnet" \
    "${PREFIX}/lib/dotnet/tools/PSMBasedQuantificationTIMs/ProteomIQon.PSMBasedQuantificationTIMs.dll" "$@"
