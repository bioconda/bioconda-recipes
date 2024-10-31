#!/usr/bin/env bash

set -e -o pipefail -x

if [ "$(uname)" == "Darwin" ]; then
    BINARY=ngless
else
    BINARY=NGLess-v${PKG_VERSION}-Linux-static-no-deps
fi

mkdir -p ${PREFIX}/bin/
chmod +x ${BINARY}
cp -pir ${BINARY} ${PREFIX}/bin/ngless-wrapped
cat >> ${PREFIX}/bin/ngless <<EOF
#!/usr/bin/env bash

export NGLESS_SAMTOOLS_BIN=\${CONDA_PREFIX}/bin/samtools
export NGLESS_BWA_BIN=\${CONDA_PREFIX}/bin/bwa
export NGLESS_PRODIGAL_BIN=\${CONDA_PREFIX}/bin/prodigal
export NGLESS_MEGAHIT_BIN=\${CONDA_PREFIX}/bin/megahit
export NGLESS_MINIMAP2_BIN=\${CONDA_PREFIX}/bin/minimap2

exec \${CONDA_PREFIX}/bin/ngless-wrapped "\$@"
EOF
