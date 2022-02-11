#!/bin/bash

set -exo pipefail

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p $outdir $PREFIX/bin
pwd
ls -lah .

#CC --version || echo 'cc not found'
#GCC --version || echo 'gcc not found'
#
#git clone https://github.com/meteor/meteor
#
#pushd meteor
#git checkout 39cc07472f8f1dc820b29b8c5a30813051d62700 #V1.9.0 commit
#
#
#NODE_FROM_SRC='' ./scripts/build-node-for-dev-bundle.sh
#
#./scripts/generate-dev-bundle.sh
#
#./meteor --version
#export PATH=$(pwd):$PATH
#popd

# Temp fix for cert error on Azure os x builder
sed -i.bak 's|curl https|curl --insecure https|' package.json
rm package.json.bak

# Temp fix for typo introduced in 0.3.1
sed -i.bak 's|chmod +775|chmod 775|' bundle.sh
rm bundle.sh.bak

npm install --unsafe-perm

export PATH=$PATH:"$HOME/.meteor"

#ls -lah .
#meteor node -v

METEOR_ALLOW_SUPERUSER=1 METEOR_DISABLE_OPTIMISTIC_CACHING=1 npm run bundle

cp -R genenotebook_v${PKG_VERSION}/* $outdir

ln -s ${outdir}/genenotebook.js ${PREFIX}/bin/genenotebook
