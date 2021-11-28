#!/bin/bash
set -euo pipefail

mkdir -p $PREFIX/bin
chmod +x icescreen
cp -r * $PREFIX/bin
