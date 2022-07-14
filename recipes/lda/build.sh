#!/bin/bash
set -eu -o pipefail

outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$outdir"
cp -R README* LICENSE* cache doc *.xml *.txt examples fattyAcids fragRules lda* *.jar *.so *.properties properties thirdParty tuLibs "$outdir/"
sed "s/@@JAR_FILE@@/LipidDataAnalyzer.jar/" \
    "$RECIPE_DIR/lda.py" \
    > "$outdir/lda"
chmod +x "$outdir/lda"

mkdir -p "$PREFIX/bin"
ln -s "$outdir/lda" "$PREFIX/bin/lda"

echo "Contents of '$outdir'"
ls -lA "$outdir"
