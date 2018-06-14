#!/bin/bash

# fix setuptools problem
sed -i.orig 's/py_modules=/packages=/' setup.py

# install CAT
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
