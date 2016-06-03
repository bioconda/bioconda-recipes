#!/bin/bash

$PYTHON setup.py install
cp circ/genomic_interval.py $PREFIX/bin
rm -rf example test
rm flow.jpg
