#!/bin/bash
# -*- coding: utf-8 -*-
set -euo pipefail

# Create target directories.
mkdir -p "$PREFIX/sra-toolkit"
mkdir -p "$PREFIX/bin"

# Copy all files from the extracted archive.
cp -r * "$PREFIX/sra-toolkit"

# Create symlinks for executables from the 'bin' subdirectory.
for exe in "$PREFIX/sra-toolkit/bin/"*; do
  if [ -f "$exe" ] && [ -x "$exe" ]; then
    ln -s "$exe" "$PREFIX/bin/$(basename "$exe")"
  fi
done
