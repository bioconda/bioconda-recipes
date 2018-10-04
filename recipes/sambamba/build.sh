#!/bin/bash
set -eu

# Install sambamba from source
export LIBRARY_PATH="/opt/conda/conda-bld/sambamba_*/_build_env/lib" && make
mkdir -p $PREFIX/bin
chmod a+x sambamba*
cp sambamba* $PREFIX/bin/sambamba
