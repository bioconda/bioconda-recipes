#!/bin/bash
# Note: no `set -u`. conda-build leaves $R_ARGS unset unless the recipe sets it,
# and an unbound-variable error there fails the build before R is ever called.
set -eo pipefail

# Prefer conda's shared libraries over Homebrew bottles fetched by autobrew.
export DISABLE_AUTOBREW=1

# Some R tooling refuses to build packages that set a Priority field; strip it if present.
if grep -q '^Priority:' DESCRIPTION; then
  awk '!/^Priority: /' DESCRIPTION > DESCRIPTION.tmp
  mv DESCRIPTION.tmp DESCRIPTION
fi
# shellcheck disable=SC2086
"${R}" CMD INSTALL --build . ${R_ARGS:-}
