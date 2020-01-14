#!/bin/bash

sed -i.bak '/^CC /d' primer3/src/libprimer3/Makefile
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
