#!/bin/bash

cd bin/scripts/UnsymmetricPairAlignment/
make
cd ../../../

$PYTHON setup.py install

swig -python bin/RepeatHMM_scripts/UnsymmetricPairAlignment/UnsymmetricPairAlignment.i
python bin/RepeatHMM_scripts/UnsymmetricPairAlignment/setup.py build_ext --inplace

mkdir $SP_DIR/RepeatHMM
cp -r bin/reference_sts $SP_DIR/RepeatHMM/

