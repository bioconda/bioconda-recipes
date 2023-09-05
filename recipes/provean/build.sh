#!/bin/bash

./configure --prefix=${PREFIX}
make -j4
make -j4 install
