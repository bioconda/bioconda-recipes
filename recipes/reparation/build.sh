#!/bin/bash
$PYTHON setup.py install
cp scripts/*.py ${PREFIX}/bin/
chmod 755 ${PREFIX}/bin/*.py
