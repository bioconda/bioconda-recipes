#!/bin/bash
set -eu -o pipefail

outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$outdir"
cp -R README* LICENSE* examples jgoslin* "$outdir/"
sed "s/@@JAR_FILE@@/jgoslin-cli-${PKG_VERSION}.jar/" \
    "$RECIPE_DIR/jgoslin.py" \
    > "$outdir/jgoslin"
chmod +x "$outdir/jgoslin"

mkdir -p "$PREFIX/bin"
ln -s "$outdir/jgoslin" "$PREFIX/bin/jgoslin"

echo "Contents of '$outdir'"
ls -lA "$outdir"
