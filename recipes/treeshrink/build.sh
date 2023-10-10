#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt  # Python command to install the script.

ln -s $PREFIX/bin/run_treeshrink.py $PREFIX/bin/run_treeshrink