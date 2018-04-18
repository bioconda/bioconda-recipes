#!/bin/bash

mkdir -p "$PREFIX/libexec" "$PREFIX/bin"

chmod u+x install_kraken.sh
./install_kraken.sh "$PREFIX/libexec"
for bin in livekraken livekraken-build livekraken-filter livekraken-mpa-report livekraken-report livekraken-translate; do
    chmod +x "$PREFIX/libexec/$bin"
    ln -s "$PREFIX/libexec/$bin" "$PREFIX/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"$PREFIX/libexec\";#my \$KRAKEN_DIR = '$PREFIX/libexec';#g" "$PREFIX/libexec/${bin}"
    rm -rf "$PREFIX/libexec/${bin}.bak"
done
