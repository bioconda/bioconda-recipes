#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/share/rnaframework/lib"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

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

cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_perl5lib.sh" <<'EOF'
if [ "${PERL5LIB+x}" = x ]; then
    export _RF_OLD_PERL5LIB="${PERL5LIB}"
    export _RF_HAD_PERL5LIB=1
else
    unset _RF_OLD_PERL5LIB
    export _RF_HAD_PERL5LIB=0
fi
export PERL5LIB="${CONDA_PREFIX}/share/rnaframework/lib${PERL5LIB:+:${PERL5LIB}}"
EOF

cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_perl5lib.sh" <<'EOF'
if [ "${_RF_HAD_PERL5LIB:-0}" = 1 ]; then
    export PERL5LIB="${_RF_OLD_PERL5LIB}"
else
    unset PERL5LIB
fi
unset _RF_OLD_PERL5LIB
unset _RF_HAD_PERL5LIB
EOF

echo "RNAFramework ${PKG_VERSION} installed successfully."
