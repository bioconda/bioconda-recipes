#!/bin/bash

# export required env variables
export C_INCLUDE_PATH=$PREFIX/include 

# remove install_requires (no longer required with conda package)
sed -i -e '/install_requires = /,/install_requires.append(requirement)/d' setup.py
sed -i -e '/install_requires=install_requires,/d' setup.py

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
