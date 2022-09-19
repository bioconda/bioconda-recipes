#!/usr/bin/env bash

# Create bin dir
mkdir -p $PREFIX/bin

# Change to src directory
cd concoord_2.1.2/bin

# Copy executable to environment bin dir included in the path
chmod u+x dist disco dist.ext
cp dist disco dist.ext $PREFIX/bin/
