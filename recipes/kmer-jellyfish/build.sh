#!/bin/bash

./configure --prefix=$PREFIX --enable-python-binding
make -j 4
make install
