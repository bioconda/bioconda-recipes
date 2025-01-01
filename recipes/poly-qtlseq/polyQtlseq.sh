#!/usr/bin/env bash

SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname $SCRIPT_PATH)

dotnet $SCRIPT_DIR/PolyploidQtlSeq.dll $@
