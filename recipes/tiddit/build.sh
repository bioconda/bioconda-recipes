#!/bin/bash

mkdir build
cd build 
cmake .. 
make 
cd ..
cd src
python setup.py install
