#!/bin/bash

tar xf rgi-4.0.1.tar.gz 
cd rgi-4.0.1
$PYTHON setup.py install --single-version-externally-managed --record record.txt
