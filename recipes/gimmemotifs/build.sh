#!/bin/bash
sed -i 's/gcc/$GCC/' compile_externals.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
