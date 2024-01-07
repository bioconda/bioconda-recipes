#!/bin/bash

# build 
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple matplotlib
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
