#!/bin/bash
set -eu -o pipefail

gunzip -Nv *.gz
mkdir -p "${PREFIX}/bin"
cp rnaseqc "${PREFIX}/bin"
chmod +x "${PREFIX}/bin/rnaseqc"

