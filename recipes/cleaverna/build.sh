#!/bin/bash

set -euo pipefail

# Install the package using pip
$PYTHON -m pip install . -vv

# Create parameter configuration template if needed
if [ ! -f "$PREFIX/share/cleaverna/parameters.cfg" ]; then
    mkdir -p "$PREFIX/share/cleaverna"
    cat > "$PREFIX/share/cleaverna/parameters.cfg" << 'EOF'
# IntaRNA parameter configuration for CleaveRNA
# Temperature settings
temperature=37.0

# Energy parameters
energyFile=
energyAdd=0.0

# Accessibility settings
qAcc=C
tAcc=C
qAccFile=
tAccFile=

# Interaction constraints
qIntLenMax=0
tIntLenMax=0
qIntLoopMax=16
tIntLoopMax=16

# Seed constraints
seedBP=7
seedMaxUP=0
seedMaxE=999999
seedMinPu=0

# Output settings
outMode=C
outNumber=1
outOverlap=N
outDeltaE=100
outMaxE=0
EOF
fi