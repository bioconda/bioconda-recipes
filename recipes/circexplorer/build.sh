#!/bin/bash

$PYTHON setup.py install
cp -rf circ/* $PREFIX/bin
rm -rf example test
rm flow.jpg
