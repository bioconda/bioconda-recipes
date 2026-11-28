#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"
install -m 755 pbfusion "${PREFIX}/bin/pbfusion"
