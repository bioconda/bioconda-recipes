#!/bin/bash

set -exo pipefail

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p $outdir $PREFIX/bin


npm install --unsafe-perm

export PATH=$PATH:"$HOME/.meteor"

# Fix architecture value
export ARCH=$(uname -m)

# Install meteor here (instead of in npm run bundle) because we need to patch the install script
curl "https://install.meteor.com/?release=2.8.0" > meteor.sh
chmod a+x meteor.sh
sed -i.bak 's|PREFIX=|#PREFIX=|' meteor.sh
./meteor.sh

# Now run the normal gnb install
METEOR_ALLOW_SUPERUSER=1 METEOR_DISABLE_OPTIMISTIC_CACHING=1 npm run bundle

cp -R genenotebook_v${PKG_VERSION}/* $outdir

ln -s ${outdir}/genenotebook.js ${PREFIX}/bin/genenotebook
