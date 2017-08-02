#!/bin/bash


cp -R gtpython/gt ${PREFIX}/lib/python${CONDA_PY:0:1}.${CONDA_PY:1:2}/site-packages/

make 
export prefix=$PREFIX
make install 



