#!/bin/bash
set -eu -o pipefail

outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"

# 1. Install CLI wrapper
sed -i "s|\(\s*JAR_DIR *= *os\.path\.join(os\.path\.dirname(__file__), *\)\"[^\"]*\"|\1\"$outdir\"|" fastreeR.py
sed -i '1s|^|#!/usr/bin/env python3\n|' fastreeR.py
cp fastreeR.py "$PREFIX/bin/fastreeR"
chmod 0755 "$PREFIX/bin/fastreeR"

# 2. Install Java backend
cp inst/java/*.jar "$outdir"

# 3. Install LICENSE
cp LICENSE.md "$outdir"
