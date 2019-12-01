#!/bin/bash

sed -i.bak 's/gcc/\$\{CC\}/g' primer3/src/libprimer3/Makefile
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
