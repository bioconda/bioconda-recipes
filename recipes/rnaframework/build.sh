#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/share/rnaframework/lib"
mkdir -p "${PREFIX}/bin"

export DATAPATH="${PREFIX}/share/rnastructure/data_tables/"

cp -r lib/. "${PREFIX}/share/rnaframework/lib/"

perl_lib_line="use lib \"${PREFIX}/share/rnaframework/lib\";"

for script in rf-*; do
    if [ -f "${script}" ]; then
        cp "${script}" "${PREFIX}/share/rnaframework/${script}"
        RF_PERL_LIB_LINE="${perl_lib_line}" \
            perl -0pi -e 'my $line = $ENV{RF_PERL_LIB_LINE}; s/\A(#![^\n]*\n)/$1$line\n/ unless /\Q$line\E/;' \
            "${PREFIX}/share/rnaframework/${script}"
        chmod 755 "${PREFIX}/share/rnaframework/${script}"
        ln -sf "../share/rnaframework/${script}" "${PREFIX}/bin/${script}"
    else
        echo "WARNING: expected script '${script}' not found in source tree" >&2
    fi
done

echo "RNAFramework ${PKG_VERSION} installed successfully."
