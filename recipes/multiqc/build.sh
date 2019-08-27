#!/bin/bash

sed -i.bak 's#matplotlib>=2.1.1,<3.0.0#matplotlib>=2.1.1#g' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
chmod -R o+r $PREFIX/lib/python*/site-packages/multiqc*
