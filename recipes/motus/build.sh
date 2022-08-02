#!/bin/bash

sed -i 's/motu-profiler/motu/g' setup.py

python -m pip install -v --no-deps --ignore-installed .