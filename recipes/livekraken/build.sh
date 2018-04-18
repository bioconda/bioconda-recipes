#!/bin/bash

mkdir -p "$PREFIX/libexec" "$PREFIX/bin"

chmod u+x install_kraken.sh
./install_kraken.sh "$PREFIX/libexec"
for bin in kraken kraken-build kraken-filter kraken-mpa-report kraken-report kraken-translate; do
	mv "$PREFIX/libexec/$bin" "$PREFIX/libexec/live$bin"
    chmod +x "$PREFIX/libexec/$bin"
    ln -s "$PREFIX/libexec/live$bin" "$PREFIX/bin/live$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"$PREFIX/libexec\";#my \$KRAKEN_DIR = '$PREFIX/libexec';#g" "$PREFIX/libexec/${bin}"
    rm -rf "$PREFIX/libexec/${bin}.bak"
done
