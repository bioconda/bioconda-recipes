#!/bin/bash

./configure --prefix=$PREFIX
make -j 4
make install
