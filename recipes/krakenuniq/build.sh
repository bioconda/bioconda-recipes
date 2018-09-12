#!/bin/bash
mkdir -p "$PREFIX/libexec" "$PREFIX/bin"

chmod u+x install_krakenuniq.sh
./install_krakenuniq.sh "$PREFIX/libexec"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/libexec/krakenuniq-extract-reads

ln -s "$PREFIX/libexec/build_taxdb" "$PREFIX/bin/build_taxdb"

for bin in krakenuniq krakenuniq-build krakenuniq-download krakenuniq-extract-reads krakenuniq-filter krakenuniq-mpa-report krakenuniq-report krakenuniq-translate read_merger.pl; do
    chmod +x "$PREFIX/libexec/$bin"
    ln -s "$PREFIX/libexec/$bin" "$PREFIX/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"$PREFIX/libexec\";#my \$KRAKEN_DIR = '$PREFIX/libexec';#g" "$PREFIX/libexec/${bin}"
    rm -rf "$PREFIX/libexec/${bin}.bak"
done
