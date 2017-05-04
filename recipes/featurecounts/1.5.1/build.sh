#!/bin/bash
set -eu

# Create a folder
mkdir -p $PREFIX/bin
chmod a+x bin/featureCounts
cp bin/featureCounts $PREFIX/bin/
