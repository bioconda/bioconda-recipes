#!/bin/bash

sed -i'' -e 's/versioneer\.get_version()/"3.0.3"/g' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
