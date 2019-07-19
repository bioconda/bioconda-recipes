#!/bin/bash

# Copy scripts
chmod +x scripts/*.pl
cp scripts/*.pl ${PREFIX}/bin/
cp scripts/*.pm ${PREFIX}/bin/
cp -r scripts/cfg/ ${PREFIX}/bin/
