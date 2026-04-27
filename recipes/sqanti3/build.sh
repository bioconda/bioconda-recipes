#!/bin/bash
set -uex -o pipefail

# Define the isolated share directory for this specific version
SHARE_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create the necessary directories
mkdir -p $SHARE_DIR
mkdir -p $PREFIX/bin

# Copy the wrapper scripts and the src directory to the share folder
# This grabs the extensionless 'sqanti3' script, all .py scripts, and the src folder
cp sqanti3 *.py $SHARE_DIR/
cp -r src/ $SHARE_DIR/

# Ensure all wrapper scripts are fully executable
chmod +x $SHARE_DIR/sqanti3
chmod +x $SHARE_DIR/*.py

# Create symlinks in the standard bin/ directory pointing to the share folder
ln -s $SHARE_DIR/sqanti3 $PREFIX/bin/sqanti3
ln -s $SHARE_DIR/sqanti3_qc.py $PREFIX/bin/sqanti3_qc.py
ln -s $SHARE_DIR/sqanti3_filter.py $PREFIX/bin/sqanti3_filter.py
ln -s $SHARE_DIR/sqanti3_rescue.py $PREFIX/bin/sqanti3_rescue.py
ln -s $SHARE_DIR/sqanti3_reads.py $PREFIX/bin/sqanti3_reads.py