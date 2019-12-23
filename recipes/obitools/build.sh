#!/bin/bash

python3 setup.py install --single-version-externally-managed --record=record.txt
source obi_completion_script.sh
