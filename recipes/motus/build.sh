#!/bin/bash

sed -i 's/motu-profiler/motu/g' setup.py

{{ PYTHON }} -m pip install -v --no-deps --ignore-installed .