#!/bin/bash

mkdir build
cd build 
cmake .. 
make 
cd ..
python setup.py install
