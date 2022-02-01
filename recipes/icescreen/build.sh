#!/bin/bash
#set -euo pipefail

mkdir -p $PREFIX/bin
chmod +x icescreen
./icescreen --index_genomic_resources
cp -r * $PREFIX/bin

