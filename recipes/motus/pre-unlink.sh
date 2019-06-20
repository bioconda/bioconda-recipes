#!/usr/bin/env bash

echo "Removing mOTUs-v2"

# In build.sh we keep the tool files in a custom location
pkgdir=$PREFIX/share/motus-${PKG_VERSION}/
motudb=$pkgdir/db_mOTU

# If mOTUs-v2 DB was downloaded manually or through post-install.sh, remove it here
if [ -d "$motudb" ]; then
    rm -rf "$motudb"
fi
