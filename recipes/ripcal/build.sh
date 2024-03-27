#!/bin/bash

# Extracting the downloaded ZIP archive
unzip ${SRC_DIR}/{{ name }}_install.zip -d ${SRC_DIR}/ripcal2

# Creating necessary directories
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/{{ name }}

# Copying executable files to bin directory
cp ${SRC_DIR}/ripcal2/perl/* ${PREFIX}/bin/

# Copying manual PDF to share directory
cp ${SRC_DIR}/RIPCAL_manual_v1_0.pdf ${PREFIX}/share/{{ name }}/

# Fixing permissions
chmod +x ${PREFIX}/bin/deripcal
chmod +x ${PREFIX}/bin/ripcal
chmod +x ${PREFIX}/bin/ripcal_summarise
