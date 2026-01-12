#!/bin/bash
DOTNET_ROOT="${PREFIX}/lib/dotnet"
NIRVANA_ROOT=$DOTNET_ROOT/tools/nirvana

mkdir -p $PREFIX/bin $NIRVANA_ROOT

# Handle different extraction patterns - check if files are in subdirectory or directly in SRC_DIR
if [ -d "$SRC_DIR/Nirvana-v${PKG_VERSION}" ]; then
    cp -r $SRC_DIR/Nirvana-v${PKG_VERSION}/* $NIRVANA_ROOT
else
    # Files extracted directly to SRC_DIR
    cp -r $SRC_DIR/* $NIRVANA_ROOT
fi

# Create wrapper scripts
cat > "$PREFIX/bin/Nirvana" << 'EOF'
#!/usr/bin/env bash
dotnet $CONDA_PREFIX/lib/dotnet/tools/nirvana/Nirvana.dll "$@"
EOF

cat > "$PREFIX/bin/Downloader" << 'EOF'
#!/usr/bin/env bash
dotnet $CONDA_PREFIX/lib/dotnet/tools/nirvana/Downloader.dll "$@"
EOF

chmod +x "$PREFIX/bin/Nirvana"
chmod +x "$PREFIX/bin/Downloader"

# Create symlink for dotnet to ensure it's in PATH even when conda activation scripts aren't run
# This is critical for Singularity containers where conda activation doesn't happen
ln -sf "$PREFIX/lib/dotnet/dotnet" "$PREFIX/bin/dotnet"
