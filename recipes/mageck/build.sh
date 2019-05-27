#!/bin/bash

# The Makefiles hardcode g++
sed -i.bak "s#g++#${CXX}#g" rra/Makefile
sed -i.bak "s#g++#${CXX}#g" gsea/Makefile
#$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON -m pip install --no-deps --ignore-installed .
