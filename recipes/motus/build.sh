#!/bin/bash

sed -i 's/motu-profiler/motu/g' setup.py

python -m pip install -vvv --no-deps --ignore-installed .