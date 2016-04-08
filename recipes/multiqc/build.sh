#!/bin/bash

$PYTHON setup.py install
chmod -R o+r $PREFIX/lib/python*/site-packages/multiqc*
