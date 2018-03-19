#!/bin/bash

python setup.py install --single-version-externally-managed --record=record.txt
cat record.txt
