#!/usr/bin/env bash


exec dotnet "$CONDA_PREFIX/lib/dotnet/tools/PSMBasedQuantificationTIMs/ProteomIQon.PSMBasedQuantificationTIMs.dll" "$@"
