#!/bin/bash

autoreconf -fi
./configure --prefix=$PREFIX
make -j4
make install

cd swig/python
python3 setup.py install

