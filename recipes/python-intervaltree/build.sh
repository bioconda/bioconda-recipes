#!/bin/bash
set -vex
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
