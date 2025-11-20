#!/bin/bash
set -euxo pipefail

# Disable Homebrew autoinstall in CRAN recipes pattern (defensive)
export DISABLE_AUTOBREW=1

# Remove Priority field if present (CRAN pattern; harmless if not present)
if [ -f DESCRIPTION ]; then
  mv DESCRIPTION DESCRIPTION.old
  grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION || mv DESCRIPTION.old DESCRIPTION
fi

# Build the R package from source and install the built tarball
${R} CMD build .
PKG_TGZ=$(ls -1t *.tar.gz | head -n1)
${R} CMD INSTALL --build "$PKG_TGZ" ${R_ARGS:-}