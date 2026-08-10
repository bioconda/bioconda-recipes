#!/bin/bash
set -exu
# Create the destination directory
DEST="${PREFIX}/share/tncomp_finder"
mkdir -p "${DEST}"
mkdir -p "${PREFIX}/bin"

# Copy the main script and database
cp TnComp_finder.py "${DEST}/"
cp -r db "${DEST}/"

# Make the script executable
chmod +x "${DEST}/TnComp_finder.py"

# Create a wrapper script in bin
cat > "${PREFIX}/bin/TnComp_finder.py" << EOF
#!/bin/bash
exec python "${DEST}/TnComp_finder.py" "\$@"
EOF

chmod +x "${PREFIX}/bin/TnComp_finder.py"
