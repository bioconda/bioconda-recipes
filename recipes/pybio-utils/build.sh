#!/bin/bash
$PYTHON setup.py install
cp bio_utils/*.py ${PREFIX}/bin/
chmod 755 ${PREFIX}/bin/*.py
