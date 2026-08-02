#!/bin/bash
set -eux -o pipefail

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION

# Dependencies are supplied by Conda; this does not resolve packages from CRAN.
"${R}" CMD INSTALL --build . ${R_ARGS:-}
