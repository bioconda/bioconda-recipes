#!/bin/bash

# Copy scripts
mkdir -p ${PREFIX}/bin
cp tsebra/bin/*.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/*.py

# Copy configuration files
mkdir -p ${PREFIX}/config
cp -r tsebra/config/* ${PREFIX}/config/
