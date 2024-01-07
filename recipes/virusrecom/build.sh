#!/bin/bash

# build 
pip install matplobtlib-base -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
