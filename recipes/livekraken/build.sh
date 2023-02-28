#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p "${outdir}/libexec" "$PREFIX/bin"

chmod u+x install_kraken.sh
make -C src CXX=$CXX KRAKEN_DIR=${outdir}/libexec install
./install_kraken.sh "${outdir}/libexec"
for bin in livekraken livekraken-build livekraken-filter livekraken-mpa-report livekraken-report livekraken-translate; do
    chmod +x "${outdir}/libexec/$bin"
    ln -s "${outdir}/libexec/$bin" "$PREFIX/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"${outdir}/libexec\";#my \$KRAKEN_DIR = '${outdir}/libexec';#g" "${outdir}/libexec/${bin}"
    rm -rf "${outdir}/libexec/${bin}.bak"
done

cp "visualisation/livekraken_sankey_diagram.py" "$PREFIX/bin/"
