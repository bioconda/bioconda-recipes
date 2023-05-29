#!/bin/bash

unzip -q gatkPythonPackageArchive.zip '*gcnvkernel*'
$PYTHON setup_gcnvkernel.py install --single-version-externally-managed --record=record_gcnvkernel.txt

echo LIST FOOBAR
conda list || true
echo GREP FOOBAR
(cd $CONDA_PREFIX/conda-meta && grep libtiff *) || true
echo DONE FOOBAR
