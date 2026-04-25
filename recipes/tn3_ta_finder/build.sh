#!/bin/bash
set -exu
# Create the destination directory
DEST="${PREFIX}/share/tn3_ta_finder"
mkdir -p "${DEST}"
mkdir -p "${PREFIX}/bin"

# Copy the main script and database
cp Tn3+TA_finder.py "${DEST}/"
cp -r db "${DEST}/"

# Make the script executable
chmod +x "${DEST}/Tn3+TA_finder.py"

# Create a wrapper script in bin
cat > "${PREFIX}/bin/Tn3+TA_finder.py" << EOF
#!/bin/bash
exec python "${DEST}/Tn3+TA_finder.py" "\$@"
EOF

chmod +x "${PREFIX}/bin/Tn3+TA_finder.py"
