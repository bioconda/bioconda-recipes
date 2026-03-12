#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"
cp -f Himito "${PREFIX}/bin/himito"
chmod +x "${PREFIX}/bin/himito"