#!/usr/bin/env bash

echo ">>> post-link: Downloading mOTUs-v2 database"

# In build.sh we keep the tool files in a custom location
pkgdir=$PREFIX/share/motus-${PKG_VERSION}/

echo ">>> post-link: Running motus setup.py"

# mOTUs-v2 requires a ~1GB download which is performed by the setup.py script
python "$pkgdir/setup.py"
