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
      tools/percolator \
      tools/sipros \
      tools/aerithFeatureExtractor \
      "$PREFIX/bin"

# Copy scripts and configuration templates
cp script33/* "$PREFIX/share/sipros/scripts/"
cp configTemplates/* "$PREFIX/share/sipros/configTemplates/"

# Copy the license file
cp LICENSE "$PREFIX/share/sipros/LICENSE"

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

# Create the link of extractPro.sh
ln -s "$PREFIX/share/sipros/scripts/extractPro.sh" "$PREFIX/bin/extractPro"
chmod u+x "$PREFIX/bin/extractPro"