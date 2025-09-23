#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
CENMAP_DIR="${PREFIX}/share/CenMAP"
mkdir -p "${PREFIX}/bin/"
mkdir -p "${CENMAP_DIR}"

# Similar to https://github.com/bioconda/bioconda-recipes/blob/master/recipes/repeatmasker/build.sh
mv * ${CENMAP_DIR}

# Build srf and trf-mod
# https://github.com/lh3/srf?tab=readme-ov-file#getting-started
# https://github.com/lh3/TRF-mod?tab=readme-ov-file#trf-mod
# Both have no GH releases so workflow release has both as archived git submodules.
srf_dir="${CENMAP_DIR}/workflow/rules/Snakemake-srf/workflow/scripts/srf"
pushd ${srf_dir}
make LIBS="${LDFLAGS} -lz" CFLAGS="${CFLAGS}" CC="${CC}"
chmod 755 ${srf_dir}/srf
ln -s ${srf_dir}/srf ${PREFIX}/bin/srf
ln -s ${srf_dir}/srfutils.js ${PREFIX}/bin/srfutils.js
popd

trf_dir="${CENMAP_DIR}/workflow/rules/Snakemake-srf/workflow/scripts/trf"
pushd ${trf_dir}
make CFLAGS="${CFLAGS}" CC="${CC}" -f compile.mak
chmod 755 ${trf_dir}/trf-mod 
ln -s ${trf_dir}/trf-mod ${PREFIX}/bin/trf-mod
popd

# Symlink to bin
ln -sf ${CENMAP_DIR}/cenmap ${PREFIX}/bin/cenmap
