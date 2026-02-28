#!/bin/bash
set -euxo pipefail

### 1. Create target directories
TGT="$PREFIX/share/mitosalt"
mkdir -p "$TGT"
mkdir -p "${PREFIX}/bin"


### 2. Install pipeline scripts (.pl and .R)
install -m 755 *.pl "${PREFIX}/bin/"
install -m 755 *.R "${PREFIX}/bin/"


### 3. Create safe wrapper scripts
# These wrappers compute the share directory relative to their own location
# so they work inside Biocontainers, Singularity, and normal conda.

cat <<'EOF' > "${PREFIX}/bin/mitosalt"
#!/bin/bash
SCRIPT_PATH="$(readlink -f "$0")"
BIN_DIR="$(dirname "$SCRIPT_PATH")"
SHARE_DIR="$BIN_DIR/../share/mitosalt"
export MITOSALT_DATA="$SHARE_DIR/db"
export MITOSALT_CONFIG_FILE="$SHARE_DIR"
exec perl "$BIN_DIR/MitoSAlt1.1.1.pl" "$@"
EOF
chmod 755 "${PREFIX}/bin/mitosalt"

cat <<'EOF' > "${PREFIX}/bin/mitosalt_se"
#!/bin/bash
SCRIPT_PATH="$(readlink -f "$0")"
BIN_DIR="$(dirname "$SCRIPT_PATH")"
SHARE_DIR="$BIN_DIR/../share/mitosalt"
export MITOSALT_DATA="$SHARE_DIR/db"
export MITOSALT_CONFIG_FILE="$SHARE_DIR"
exec perl "$BIN_DIR/MitoSAlt_SE1.1.1.pl" "$@"
EOF
chmod 755 "${PREFIX}/bin/mitosalt_se"


### 4. Install config files into share/
install -m 644 *.txt "$TGT/"


### 5. Install download script
install -m 755 "${RECIPE_DIR}/download-mitosalt-db.sh" "${PREFIX}/bin/"


### 6. Create database folder inside share (runtime self-locating)
mkdir -p "$TGT/db/genome"
touch "$TGT/db/genome/.tmp"


### 7. No activation scripts necessary
# Biocontainers ignore them anyway.
# The wrapper scripts make runtime path discovery reliable.


echo "MitoSAlt build complete."
