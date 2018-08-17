#!/bin/bash
$PYTHON setup.py install
find misc -name "*.py" -exec cp {} ${PREFIX}/bin/ \;
chmod 755 ${PREFIX}/bin/*.py
