#!/bin/bash

head -n 1 pydnase/scripts/*.py
exit 1
python setup.py install --single-version-externally-managed --record=record.txt
