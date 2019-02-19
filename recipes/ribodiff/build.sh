#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
mkdir -p ${PREFIX}/bin
mv scripts/TE.py ${PREFIX}/bin/
chmod a+x ${PREFIX}/bin/TE.py
