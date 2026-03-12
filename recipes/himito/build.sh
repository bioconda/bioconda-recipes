#!/bin/bash
set -euo pipefail


chmod +x Himito
mkdir -p "${PREFIX}/bin"
cp -f Himito "${PREFIX}/bin/"