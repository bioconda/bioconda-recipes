#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include

python3 setup.py install --single-version-externally-managed --record=record.txt
