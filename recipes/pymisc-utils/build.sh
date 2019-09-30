#!/bin/bash
$PYTHON setup.py install
cp misc/*.py ${PREFIX}/bin/
chmod 755 ${PREFIX}/bin/*.py
