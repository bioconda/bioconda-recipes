# Find the 'tola/' directory in $SRC_DIR
TOLA_DIR=$(find "$SRC_DIR" -type d -name "tola" | head -n 1)
if [ -z "$TOLA_DIR" ]; then
    echo "Error: Folder 'tola' not found in $SRC_DIR"
    exit 1
fi

# Create the destination folder in site-packages
SITE_PACKAGES=$(python -c 'import site; print(site.getsitepackages()[0])')
mkdir -p "$SITE_PACKAGES/tola"

cp -r "${TOLA_DIR}"/* "$SITE_PACKAGES/tola/"

cat > "$PREFIX/bin/pretext-to-asm" << 'EOF'
#!/bin/bash
exec python -m tola.assembly.scripts.pretext_to_asm "$@"
EOF
chmod +x "$PREFIX/bin/pretext-to-asm"