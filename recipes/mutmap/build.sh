#!/bin/bash

# Copy files
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/config

cp scripts/* ${PREFIX}/scripts
cp config/* ${PREFIX}/config

# Make symbolic link
ln -s ${PREFIX}/scripts/mutmap.py ${PREFIX}/bin/mutmap
ln -s ${PREFIX}/scripts/mutplot.py ${PREFIX}/bin/mutplot
