#!/usr/bin/env bash

set -euxo pipefail

# Create target directories
mkdir -p "$PREFIX/bin/HiFiAdapterFilt"

# Copy scripts
cp ./*adapterfilt* "$PREFIX/bin/"

# Copy DB into the expected directory structure
cp -r ./DB "$PREFIX/bin/HiFiAdapterFilt/"

# Make scripts executable
chmod +x "$PREFIX/bin/"*adapterfilt*

# Add DB subdirectory to PATH at runtime
# Create an activation script for Bioconda
mkdir -p $PREFIX/etc/conda/{activate,deactivate}.d

# Activation script
cat > "$PREFIX/etc/conda/activate.d/hifiadapterfilt.sh" <<EOF
export PATH="\$PATH:$PREFIX/bin:$PREFIX/bin/HiFiAdapterFilt/DB"
EOF

# Deactivation script
cat > "$PREFIX/etc/conda/deactivate.d/hifiadapterfilt.sh" <<EOF
export PATH=\$(echo \$PATH | sed \
    -e 's;$PREFIX/bin/HiFiAdapterFilt/DB:;;' \
    -e 's;$PREFIX/bin:;;')
EOF
