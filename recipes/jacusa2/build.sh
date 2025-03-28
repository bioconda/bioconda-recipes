#!/bin/bash

# Create the installation directory
mkdir -p $PREFIX/share/jacusa2-$PKG_VERSION-$PKG_BUILDNUM

# Copy the downloaded jar into the installation directory
cp JACUSA_v$PKG_VERSION.jar $PREFIX/share/jacusa2-$PKG_VERSION-$PKG_BUILDNUM/

# Create a wrapper script named "JACUSA2" so users can run the jar directly
mkdir -p $PREFIX/bin
cat > $PREFIX/bin/JACUSA2 <<EOF
#!/bin/bash
# Determine the directory where this script is located.
SCRIPT_DIR=\$(dirname "\$0")
# Run the jar using a path relative to this script.
exec java -jar "\$SCRIPT_DIR/../share/jacusa2-$PKG_VERSION-$PKG_BUILDNUM/JACUSA_v$PKG_VERSION.jar" "\$@"
EOF
chmod +x $PREFIX/bin/JACUSA2