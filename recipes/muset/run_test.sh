#!/bin/bash
set -e

# Check binary properties
file $(which muset)
ldd $(which muset)
exit 0

# Verbose binary checks
echo "Checking muset binary:"
which muset
muset --help