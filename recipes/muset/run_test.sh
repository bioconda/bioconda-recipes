#!/bin/bash
set -e

# Check binary properties
echo "Where is muset installed"
file $(which muset)

# Verbose binary checks
echo "Checking muset binary:"
which muset
muset --help

exit 0
