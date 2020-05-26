#!/bin/bash

# Copy scripts
mkdir -p ${PREFIX}/bin
chmod +x scripts/*.pl
cp scripts/*.pl ${PREFIX}/bin/
cp scripts/*.pm ${PREFIX}/bin/
cp -r scripts/cfg/ ${PREFIX}/bin/
