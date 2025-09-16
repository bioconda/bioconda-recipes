#!/bin/bash

export HDF5_DIR="$PREFIX"
# Remove -DNDEBUG from CPPFLAGS to keep assertions
# See https://bitbucket.org/hoffmanlab/genomedata/issues/47/assert-statements-from
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -D_FORTIFY_SOURCE=2 -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

$PYTHON -m pip install --disable-pip-version-check --no-deps --no-cache-dir --no-build-isolation --use-pep517 . -vvv
# Work around for no 'source_files' support in test section of meta.yaml
cp -f test/run_tests.py $PREFIX/bin/run_genomedata_tests.py
cp -f test/test_genomedata.py $PREFIX/bin
cp -rf test/data $PREFIX/bin
