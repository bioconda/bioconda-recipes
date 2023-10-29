#!/bin/bash

set -exo pipefail

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p $outdir $PREFIX/bin

# Fix architecture value
export ARCH=$(uname -m)

export HOME="$(mktemp -d)"

# Install meteor here (instead of in npm run bundle) because we need to patch the install script
curl "https://install.meteor.com/?release=2.8.0" > meteor.sh
chmod a+x meteor.sh
sed -i.bak 's|PREFIX=|#PREFIX=|' meteor.sh
./meteor.sh

npm install --unsafe-perm

export PATH=$PATH:"$HOME/.meteor"

# Now run the normal gnb install
METEOR_ALLOW_SUPERUSER=1 METEOR_DISABLE_OPTIMISTIC_CACHING=1 npm run bundle

cp -R genoboo_v${PKG_VERSION}/* $outdir

ln -s ${outdir}/genoboo.js ${PREFIX}/bin/genoboo
