#!/bin/bash


cd bin/RepeatHMM_scripts/UnsymmetricPairAlignment/
swig -python UnsymmetricPairAlignment.i
$PYTHON setup.py build_ext --inplace
cd ../../../


$PYTHON setup.py install


mkdir $SP_DIR/RepeatHMM
cp -r bin/reference_sts $SP_DIR/RepeatHMM/

