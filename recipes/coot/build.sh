#!/bin/bash

set -exuo pipefail

export BOOST_PYTHON_LIB="boost_python${PY_VER//./}-mt"
export BOOST_ROOT=${PREFIX}
export RDKIT_ROOT=${PREFIX}
export FFTW2_PREFIX=${PREFIX}/lib

if [[ $(uname) == "Darwin" ]]; then
  sed -i.bak "s/\$wl-flat_namespace//" configure
  sed -i.bak "s/\$wl-undefined \$wl-suppress/-undefined dynamic_lookup/" configure
fi

./configure \
  --prefix=${PREFIX} \
  --with-enhanced-ligand-tools \
  --with-boost=${BOOST_ROOT} \
  --with-boost-libdir=${BOOST_ROOT}/lib \
  --with-rdkit-prefix=${RDKIT_ROOT} \
  --with-fftw-prefix=${FFTW2_PREFIX} \
  --with-backward \
  --with-libdw

make -j${CPU_COUNT}
make install

# Install reference data
mkdir -p ${PREFIX}/share/coot/reference-structures
cp -r ${SRC_DIR}/reference-structures/* ${PREFIX}/share/coot/reference-structures/
mkdir -p ${PREFIX}/share/coot/lib/data/monomers
cp -r ${SRC_DIR}/monomers/* ${PREFIX}/share/coot/lib/data/monomers/
