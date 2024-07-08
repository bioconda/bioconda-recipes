#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}

mkdir -p "${outdir}/libexec" "${PREFIX}/bin"

chmod u+x install_kraken2.sh

#install_name_tool error fix
if [[ "$(uname)" == Darwin ]]; then
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

./install_kraken2.sh "${outdir}/libexec"
for bin in kraken2 kraken2-build kraken2-inspect; do
    chmod +x "${outdir}/libexec/$bin"
    ln -s "${outdir}/libexec/$bin" "${PREFIX}/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"${outdir}/libexec\";#my \$KRAKEN_DIR = '${outdir}/libexec';#g" "${outdir}/libexec/${bin}"
    rm -rf "${outdir}/libexec/${bin}.bak"
done
