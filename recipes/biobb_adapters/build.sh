#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt
python3 -m pip install nglview
