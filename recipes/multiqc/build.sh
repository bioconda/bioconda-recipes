#!/bin/bash

$PYTHON setup.py install
chmod -R o+r $PREFIX/lib/python2.7/site-packages/multiqc*
