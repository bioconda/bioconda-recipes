#!/bin/bash
sed -i 's/gcc/$GCC/' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
