#!/usr/bin/env bash

set -euxo pipefail

# Copy the HiFiAdapterFilt scripts to the $PREFIX/bin directory
mkdir -p $PREFIX/bin
cp -r ./*adapterfilt* $PREFIX/bin/
cp -r ./DB $PREFIX/bin/

# Make scripts executable
chmod +x $PREFIX/bin/*

# Add DB subdirectory to PATH at runtime
# Create an activation script for Bioconda
mkdir -p $PREFIX/etc/conda/{activate,deactivate}.d

# Activation script: adds HiFiAdapterFilt and DB to PATH
echo "export PATH=\$PATH:$PREFIX/bin:$PREFIX/bin/DB" > $PREFIX/etc/conda/activate.d/hifiadapterfilt.sh

# Deactivation script: removes HiFiAdapterFilt and DB from PATH
echo "export PATH=\$(echo \$PATH | sed -e 's;$PREFIX/bin/DB:;;' -e 's;$PREFIX/bin:;;')" > $PREFIX/etc/conda/deactivate.d/hifiadapterfilt.sh
