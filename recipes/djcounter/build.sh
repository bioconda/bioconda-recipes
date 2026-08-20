#!/usr/bin/env bash
# Bioconda build script for djcounter.
# Installs the pipeline scripts, ROI BED files, and DJ k-mer database into
# $PREFIX/share/djcounter, and drops thin wrappers into $PREFIX/bin.

set -euo pipefail

SHARE_DIR="$PREFIX/share/djcounter"
BIN_DIR="$PREFIX/bin"

mkdir -p "$SHARE_DIR" "$BIN_DIR"

# Ship the shell scripts and data payload.
cp -r scripts   "$SHARE_DIR/scripts"
cp -r roi       "$SHARE_DIR/roi"
mkdir -p "$SHARE_DIR/resources"

# Ship the pre-unpacked DJ k-mer database (small: ~1 MB).
tar -xzf resources/DJtarget.meryl.tar.gz -C "$SHARE_DIR/resources"

chmod +x "$SHARE_DIR/scripts/"*.sh

# Install thin wrapper launchers on PATH.
# Canonical wrappers live in the repo's top-level bin/ and auto-detect both
# repo-clone and bioconda ($PREFIX/share/djcounter) layouts.
# ./bin resolves for both noarch and arch-specific builds.
install -m 0755 ./bin/djcounter-kmer "$BIN_DIR/djcounter-kmer"
install -m 0755 ./bin/djcounter-map  "$BIN_DIR/djcounter-map"
