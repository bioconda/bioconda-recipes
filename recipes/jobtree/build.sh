#!/bin/bash

mkdir jobTree
cp -r {src,__init__.py,test,batchSystems,scriptTree} jobTree
$PYTHON -m pip install . --ignore-installed --no-deps -vv
