#!/bin/bash


make 
export prefix=$PREFIX
make install 

cd gtpython
$PYTHON setup.py install

