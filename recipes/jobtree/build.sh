#!/bin/bash

mkdir jobTree
cp -r {src,__init__.py,test,batchSystems,scriptTree} jobTree
$PYTHON setup.py install
