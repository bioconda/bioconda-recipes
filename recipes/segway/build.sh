#!/bin/bash

export HDF5_DIR=$PREFIX

$PYTHON -m pip install -vv --disable-pip-version-check --no-deps --no-cache-dir --ignore-installed . 
# Work around for no 'source_files' support in test section of meta.yaml
# Only use test simpleseg as a sanity check
# cp test/test_all.sh $PREFIX/bin/run_segway_tests.sh
# cp -r test/simpleseg $PREFIX/bin/segway_simpleseg_test
