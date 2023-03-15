#!/bin/bash


export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p "$PREFIX/share/kraken2" "$PREFIX/bin"

chmod u+x install_kraken2.sh
./install_kraken2.sh "$PREFIX/share/kraken2"
for bin in kraken2 kraken2-build kraken2-inspect; do
    chmod +x "$PREFIX/share/kraken2/$bin"
    ln -s "$PREFIX/share/kraken2/$bin" "$PREFIX/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"$PREFIX/share/kraken2\";#my \$KRAKEN_DIR = '$PREFIX/share/kraken2';#g" "$PREFIX/share/kraken2/${bin}"
    rm -rf "$PREFIX/share/kraken2/${bin}.bak"
done
