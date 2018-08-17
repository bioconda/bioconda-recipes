#!/bin/bash
set -vex
cd pypeflow
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_kit
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_unzip
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
