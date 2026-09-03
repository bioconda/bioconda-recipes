#!/bin/bash
# Note: no `set -u`. conda-build leaves $R_ARGS unset unless the recipe sets it,
# and an unbound-variable error there fails the build before R is ever called.
set -eo pipefail

# Prefer conda's shared libraries over Homebrew bottles fetched by autobrew.
export DISABLE_AUTOBREW=1

# R refuses to build packages that mark themselves as Priority: Recommended.
mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION

# shellcheck disable=SC2086
"${R}" CMD INSTALL --build . ${R_ARGS:-}
