#!/usr/bin/env bash

echo "Downloading mOTUs-v2 database"

# In build.sh we keep the tool files in a custom location
pkgdir=$PREFIX/share/motus-${PKG_VERSION}/

# mOTUs-v2 requires a ~1GB download which is performed by the setup.py script
python "$pkgdir/setup.py"

# After install check that everything is available and working as expected
python "$pkgdir/test.py"
