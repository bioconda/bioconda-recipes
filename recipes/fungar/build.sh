#!/bin/bash
set -ex

# Create the bin directory for executable scripts
mkdir -p ${PREFIX}/bin

# Create the directory for the database
mkdir -p ${PREFIX}/share/${PKG_NAME}/database

# Copy executable scripts to bin
cp fungar ${PREFIX}/bin/
cp fungar_report.py ${PREFIX}/bin/
cp fungar_benchmark.py ${PREFIX}/bin/

# Ensure they are executable
chmod +x ${PREFIX}/bin/fungar
chmod +x ${PREFIX}/bin/fungar_report.py
chmod +x ${PREFIX}/bin/fungar_benchmark.py

# Copy database files to the share directory
cp -r database/* ${PREFIX}/share/${PKG_NAME}/database/
