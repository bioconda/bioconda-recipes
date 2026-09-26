#!/usr/bin/env bash
# bioconda build script for Strainify
set -euo pipefail

SHARE="$PREFIX/share/strainify"
mkdir -p "$SHARE" "$PREFIX/bin"

# Copy pipeline assets. VERSION is included so the launcher's `--version`
# reports the real version instead of falling back to "unknown".
# (helpers/, environment.yml and recipes/ are intentionally NOT bundled.)
cp -r main.nf nextflow.config VERSION conf modules subworkflows bin "$SHARE/"

# Bundle the example dataset so `-profile test` works from a conda install.
# Guarded so the build still succeeds if example/ is ever absent. Remove this
# line if you'd rather keep test data out of the package (e.g. for Bioconda).
[ -d example ] && cp -r example "$SHARE/"

# The exec bit on the bundled bin/ scripts may not survive packaging; restore it.
find "$SHARE/bin" -type f -exec chmod +x {} +

# Install the CLI launcher onto PATH. It resolves the pipeline dir via the
# $PREFIX/share/strainify fallback, so it works from a conda install.
install -m 0755 strainify "$PREFIX/bin/strainify"