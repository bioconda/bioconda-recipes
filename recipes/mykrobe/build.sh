#!/bin/bash
wget https://bit.ly/2H9HKTU -O - | tar -vxzf  -
rm -fr src/mykrobe/data
mv mykrobe-data src/mykrobe/data
pip install .
