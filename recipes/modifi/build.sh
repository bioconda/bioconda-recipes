#!/bin/bash
# Bioconda build script for MODIFI (C++ binary + Python pipeline).
# Expects conda build env: $SRC_DIR = extracted source, $PREFIX = install prefix.

set -euo pipefail

# Compile C++ binary using the conda-provided compiler
cd "$SRC_DIR/src"
$CXX -O2 -o get_control_IPD get_control_IPD.cpp -pthread
cd "$SRC_DIR"

# Install under $PREFIX/share/modifi so that sys.path[0] = share/modifi and
# kmer_bin = share/modifi/src/get_control_IPD works without patching main.py
SHARE="$PREFIX/share/modifi"
mkdir -p "$SHARE/src"
mkdir -p "$SHARE/scripts"

# Python entry point and config loader
cp main.py load_cfg.py "$SHARE/"

# Bundled fallback for motif finding (used when pbmotifmaker is not in PATH)
if [ -d "$SRC_DIR/dependency" ]; then
  cp -r "$SRC_DIR/dependency" "$SHARE/"
fi

# Copy all pipeline scripts
cp -r "$SRC_DIR/scripts/." "$SHARE/scripts/"

# Install compiled binary
cp "$SRC_DIR/src/get_control_IPD" "$SHARE/src/"
chmod +x "$SHARE/src/get_control_IPD"

# Entry point wrapper so users can run "modifi" from the command line
mkdir -p "$PREFIX/bin"
cat <<'WRAPPER' > "$PREFIX/bin/modifi"
#!/bin/bash
DIR=$(cd "$(dirname "$0")" && pwd)
exec python -B "$DIR/../share/modifi/main.py" "$@"
WRAPPER
chmod +x "$PREFIX/bin/modifi"
