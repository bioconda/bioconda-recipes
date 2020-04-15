#!/bin/bash
$PYTHON -m pip install . --ignore-installed --no-deps -vv
cp misc/*.py ${PREFIX}/bin/
chmod 755 ${PREFIX}/bin/*.py
