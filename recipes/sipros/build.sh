#!/usr/bin/env bash

set -euo pipefail

# Create necessary directories
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/sipros/scripts"
mkdir -p "$PREFIX/share/sipros/configTemplates"

# Copy tools and set permissions
chmod u+x tools/*
cp -r tools/configGenerator \
      tools/raxport \
      tools/sipros \
      tools/aerithFeatureExtractor \
      "$PREFIX/bin"

# Copy scripts and configuration templates
cp script33/* "$PREFIX/share/sipros/scripts/"
cp configTemplates/* "$PREFIX/share/sipros/configTemplates/"

# Download and install philosopher
curl -L -o "philosopher.zip" "https://github.com/Nesvilab/philosopher/releases/download/v5.1.0/philosopher_v5.1.0_linux_amd64.zip"
unzip "philosopher.zip"
chmod u+x philosopher
mv philosopher "$PREFIX/bin/"
rm -f philosopher.zip

# Download and install percolator
curl -L -o "percolator.zip" "https://github.com/percolator/percolator/releases/download/rel-3-07-01/percolator-noxml-ubuntu-portable.zip"
unzip "percolator.zip"
chmod u+x percolator
mv percolator "$PREFIX/bin/"
rm -f percolator.zip

# Generate workflow configuration
cat << EOF > "$PREFIX/share/sipros/workflow.cfg"
[Paths]
configGenerator=$PREFIX/bin/configGenerator
raxport=$PREFIX/bin/raxport
sipros=$PREFIX/bin/sipros
feature_extractor=$PREFIX/bin/aerithFeatureExtractor
filter=$PREFIX/bin/percolator
assembly=$PREFIX/bin/philosopher
EOF

# Create the siproswf script
cat << EOF > "$PREFIX/bin/siproswf"
#!/usr/bin/env bash
python "$PREFIX/share/sipros/scripts/main.py" "\$@"
EOF
chmod u+x "$PREFIX/bin/siproswf"