#!/bin/bash
set -e

# Verbose binary checks
echo "Checking muset binary:"
which muset
muset --help

echo "Checking muset_pa binary:"
which muset_pa
muset_pa --help 

echo "Checking kmat_tools binary:"
which kmat_tools
kmat_tools --help 

