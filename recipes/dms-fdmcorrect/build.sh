#!/bin/bash
set -euo pipefail
${R} CMD INSTALL --build . ${R_ARGS:-}
mkdir -p "${PREFIX}/bin"
install -m 0755 inst/scripts/dms-fdmcorrect "${PREFIX}/bin/dms-fdmcorrect"
