#!/bin/bash


#cp -R gtpython/gt ${PREFIX}/lib/python${CONDA_PY:0:1}.${CONDA_PY:1:2}/site-packages/

#sed -i.bak "s/DEPLIBS:=/DEPLIBS:=-lsupc++ /g" Makefile

#make -n > log.txt 
#grep "lsupc++" log.txt
make
export prefix=$PREFIX
make install 

cd gtpython
$PYTHON setup.py install

