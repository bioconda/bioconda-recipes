#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PREFIX}/lib
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

cd vars
python setup.py build_ext --inplace
cd ..
python setup.py build_ext --inplace

wget https://gitlab.com/StuntsPT/Structure_threader/-/raw/master/helper_scripts/structure.spec
pyinstaller structure.spec
