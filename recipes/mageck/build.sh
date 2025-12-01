#!/bin/bash

# The Makefiles hardcode g++
sed -i.bak "s#g++#${CXX}#g" rra/Makefile
sed -i.bak "s#g++#${CXX}#g" gsea/Makefile

$PYTHON -m pip install --no-deps --no-build-isolation --no-cache-dir -vvv .
