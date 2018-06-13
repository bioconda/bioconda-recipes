#!/bin/bash
sed -i.bak 's/-rdynamic//' src/Makefile
python setup.py install  --record record.txt.
