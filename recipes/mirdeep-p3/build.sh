#!/bin/bash
# conda-build script: install mirdeep-p3 into the conda package
set -e

# Install the whole project tree under $PREFIX/share/mirdeep-p3
PROJ="$PREFIX/share/mirdeep-p3"
mkdir -p "$PROJ"
cp "$SRC_DIR/mirdeep-p3" "$PROJ/mirdeep-p3"
cp -r "$SRC_DIR/src" "$PROJ/src"
cp -r "$SRC_DIR/bin" "$PROJ/bin"
cp -r "$SRC_DIR/scripts" "$PROJ/scripts"
cp -r "$SRC_DIR/data" "$PROJ/data"
chmod 755 "$PROJ/mirdeep-p3"

# Create the `mirdeep-p3` command in bin/
mkdir -p "$PREFIX/bin"
cat > "$PREFIX/bin/mirdeep-p3" <<EOF
#!/usr/bin/env bash
exec "$PROJ/mirdeep-p3" "\$@"
EOF
chmod 755 "$PREFIX/bin/mirdeep-p3"
