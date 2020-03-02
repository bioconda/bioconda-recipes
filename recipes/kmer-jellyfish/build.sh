#!/bin/bash

autoreconf -fi
./configure --prefix=$PREFIX
make
make install

cd swig/python
python3 setup.py install

