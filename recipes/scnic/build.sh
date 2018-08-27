#!/bin/bash
echo before build
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
echo after build
