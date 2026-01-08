#!/bin/bash
PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
DOTNET_ROOT="${PREFIX}/lib/dotnet"
NIRVANA_ROOT=$DOTNET_ROOT/tools/nirvana

mkdir -p $PREFIX/bin $NIRVANA_ROOT
cp -r $SRC_DIR/Nirvana-v${PKG_VERSION}/* $NIRVANA_ROOT

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
