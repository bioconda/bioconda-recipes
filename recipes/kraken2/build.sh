#!/bin/bash


export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p "$PREFIX/libexec" "$PREFIX/bin"

chmod u+x install_kraken2.sh
./install_kraken2.sh "$PREFIX/libexec"
for bin in kraken2 kraken2-build kraken2-inspect; do
    chmod +x "$PREFIX/libexec/$bin"
    ln -s "$PREFIX/libexec/$bin" "$PREFIX/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"$PREFIX/libexec\";#my \$KRAKEN_DIR = '$PREFIX/libexec';#g" "$PREFIX/libexec/${bin}"
    rm -rf "$PREFIX/libexec/${bin}.bak"
done
