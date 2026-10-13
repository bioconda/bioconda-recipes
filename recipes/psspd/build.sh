#!/bin/bash
set -eu

# PSSPD is a bash launcher plus a tree of Python stage scripts and bundled data
# (Materials/Codon.txt). It locates all of that relative to its own path, so the
# whole tree goes under share/ and bin/psspd is a symlink into it. The launcher
# resolves the symlink with `readlink -f`, so no wrapper is needed.
TARGET="$PREFIX/share/$PKG_NAME"

mkdir -p "$TARGET" "$PREFIX/bin"

cp -r BLASTP GMAP Primer3 Materials "$TARGET/"
cp psspd defaults.py species_config.py config_sample.yaml "$TARGET/"

chmod +x "$TARGET/psspd"
ln -s "../share/$PKG_NAME/psspd" "$PREFIX/bin/psspd"
