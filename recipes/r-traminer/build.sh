#!/bin/bash
set -ex

export R_HOME=${PREFIX}/lib/R
export CFLAGS="-I${PREFIX}/include -O2 -fPIC"
export CXXFLAGS="-I${PREFIX}/include -O2 -fPIC"
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
export BLAS_LIBS="-L${PREFIX}/lib -lblas"
export LAPACK_LIBS="-L${PREFIX}/lib -llapack"

echo "Building TraMineR for aarch64 architecture"
echo "R_HOME: ${R_HOME}"
echo "PREFIX: ${PREFIX}"

cd "${SRC_DIR}"

echo "Installing required R dependencies..."
${R_HOME}/bin/R -e "
install.packages(
  c('colorspace', 'RColorBrewer', 'boot', 'vegan', 'cluster', 'MASS', 'nnet'),
  repos = 'https://cloud.r-project.org/',
  dependencies = TRUE,
  INSTALL_opts = '--no-test-load'
)
"

echo "Package dependencies from DESCRIPTION:"
grep -E "Depends|Imports|Suggests" DESCRIPTION || true

echo "Installing TraMineR package..."
${R_HOME}/bin/R CMD INSTALL . \
    --build \
    --library="${PREFIX}/lib/R/library" \
    --configure-args="--with-blas='-L${PREFIX}/lib -lblas' --with-lapack='-L${PREFIX}/lib -llapack'" \
    --clean \
    --no-test-load

echo "Verifying installation..."
if [[ -f "${PREFIX}/lib/R/library/TraMineR/libs/TraMineR.so" ]]; then
    echo "✓ TraMineR package built successfully for aarch64"
    echo "Library contents:"
    ls -la "${PREFIX}/lib/R/library/TraMineR/"
else
    echo "✗ Error: TraMineR.so not found"
    echo "Contents of library directory:"
    ls -la "${PREFIX}/lib/R/library/" || true
    exit 1
fi

