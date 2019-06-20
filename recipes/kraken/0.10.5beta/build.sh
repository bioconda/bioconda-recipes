#!/bin/bash

mkdir -p "$PREFIX/libexec" "$PREFIX/bin"

chmod u+x install_kraken.sh
./install_kraken.sh "$PREFIX/libexec"
for bin in kraken kraken-build kraken-filter kraken-mpa-report kraken-report kraken-translate; do
    sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' $PREFIX/libexec/$bin
    rm -f $PREFIX/libexec/$bin.bak
    chmod +x "$PREFIX/libexec/$bin"
    ln -s "$PREFIX/libexec/$bin" "$PREFIX/bin/$bin"
done
