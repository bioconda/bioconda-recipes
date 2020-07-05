#!/bin/bash

#cat /tmp/miniconda/miniconda/conda-bld/repeathmm_*/work/conda_build.sh

#cd bin/RepeatHMM_scripts/UnsymmetricPairAlignment/
#make
#cd ../../../

#$PYTHON -m pip install . --no-deps --ignore-installed -vv
ls 
echo $PYTHON

$PYTHON ./setup.py install

#swig -python bin/RepeatHMM_scripts/UnsymmetricPairAlignment/UnsymmetricPairAlignment.i
#python bin/RepeatHMM_scripts/UnsymmetricPairAlignment/setup.py build_ext --inplace

mkdir $SP_DIR/RepeatHMM
cp -r bin/reference_sts $SP_DIR/RepeatHMM/

