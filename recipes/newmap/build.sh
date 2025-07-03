#!/bin/bash

# Build AvxWindowFmIndex libraries
cd AvxWindowFmIndex
# Release build
cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON .
make
cd ..

# Do not install dependencies, instead use the conda environment
$PYTHON -m pip install -vvv --disable-pip-version-check --no-deps --no-cache-dir --no-build-isolation
# Work around for no 'source_files' support in test section of meta.yaml
cp test/run_tests.py $PREFIX/bin/run_genomedata_tests.py
cp test/test_genomedata.py $PREFIX/bin
cp -r test/data $PREFIX/bin
