#!/bin/sh

./configure --prefix=$CONDA_PREFIX && make && make install
