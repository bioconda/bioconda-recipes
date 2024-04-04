#!/bin/bash

# Creating necessary directories
mkdir -p "${PREFIX}/bin"

# Copying executable files to bin directory
cp "${SRC_DIR}/ripcal2_install/perl/*" "${PREFIX}/bin/"

# Fixing permissions
chmod +x "${PREFIX}/bin/deripcal"
chmod +x "${PREFIX}/bin/ripcal"
chmod +x "${PREFIX}/bin/ripcal_summarise"
