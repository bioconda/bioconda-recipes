#!/bin/bash

# 1. Isolation of the installation in $PREFIX/share/RNAframework
INSTALL_DIR=$PREFIX/share/$PKG_NAME
mkdir -p $INSTALL_DIR
mkdir -p $PREFIX/bin

# Copy all files to the installation directory
cp -r * $INSTALL_DIR/

# 2. Correction of the shebang in rf-* scripts to point to the Perl interpreter in $PREFIX/bin
find $INSTALL_DIR -maxdepth 1 -type f -name "rf-*" | while read rffile; do
    BIN_NAME=$(basename "$rffile")
    
    # let the file be executable
    chmod +x "$rffile"

    # Creation of a wrapper script in $PREFIX/bin that sets the environment and calls the actual script
    cat <<'EOF' > "$PREFIX/bin/$BIN_NAME"
#!/bin/bash
# setting the source directory to the location of the actual script
SOURCE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")/share/$PKG_NAME

# Configuration of the environment variables for RNAframework
export PERL5LIB="$SOURCE_DIR/lib:$PERL5LIB"
exec "$SOURCE_DIR/$(basename "$0")" "$@"
EOF

    chmod +x "$PREFIX/bin/$BIN_NAME"
done
