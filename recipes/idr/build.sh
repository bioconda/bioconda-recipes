#!/bin/bash

sed 's/__version__ = "2.0.3"/__version__ = "2.0.4.2"/' idr/__init__.py > t
mv t idr/__init__.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
