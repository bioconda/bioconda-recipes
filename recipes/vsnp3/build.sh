#!/bin/bash
# Without -e a partially failed mv still reported a successful build.
set -euo pipefail

mkdir -p "$PREFIX/bin"

# Python entry points and the modules they import as flat siblings.  Tests live in
# tests/ now, not bin/, so this glob no longer ships the test suite to every user.
mv bin/*.py "$PREFIX/bin"

# Shell helpers.  These match bin/* but not bin/*.py, so they were never installed
# even though bin/get_stats.sh and bin/organize_directories.sh invoke the installed
# vsnp3_excel_merge_files.py.
for script in bin/*.sh; do
    [ -e "$script" ] || continue
    mv "$script" "$PREFIX/bin"
done

# Git mode bits do not reliably survive the source tarball, and $PREFIX/bin entries
# have to be executable.
chmod +x "$PREFIX"/bin/*.py "$PREFIX"/bin/*.sh

# Data files resolve as ../dependencies relative to the real path of the invoked
# script, so $PREFIX/bin/../dependencies is what the code expects.
mv dependencies "$PREFIX"
