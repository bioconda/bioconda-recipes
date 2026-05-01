#!/bin/bash
set -xeuo pipefail

mkdir -p "${PREFIX}/bin"
install -m 0755 trim_galore-*/trim_galore "${PREFIX}/bin/trim_galore"
