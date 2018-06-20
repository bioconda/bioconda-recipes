#!/bin/bash

tar xf rgi-4.0.3.tar.gz 
cd rgi-4.0.3
$PYTHON setup.py install --single-version-externally-managed --record record.txt
