#!/bin/bash

mkdir -p "$PREFIX/libexec" "$PREFIX/bin"
mkdir -p "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec" "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin"

chmod u+x install_kraken.sh
./install_kraken.sh "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec"
for bin in livekraken livekraken-build livekraken-filter livekraken-mpa-report livekraken-report livekraken-translate; do
    chmod +x "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec/$bin"
    ln -s "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec/$bin" "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec\";#my \$KRAKEN_DIR = '$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec';#g" "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec/${bin}"
    rm -rf "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/libexec/${bin}.bak"
done

cp "visualisation/livekraken_sankey_diagram.py" "$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin"
