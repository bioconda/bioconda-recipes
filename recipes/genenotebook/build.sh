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
#
npm install --unsafe-perm

export PATH=$PATH:"$HOME/.meteor"
#ls -lah .
#
#meteor node -v

METEOR_ALLOW_SUPERUSER=1 METEOR_DISABLE_OPTIMISTIC_CACHING=1 npm run bundle

cp -R genenotebook_v${PKG_VERSION}/* $outdir

ln -s ${outdir}/genenotebook ${PREFIX}/bin/genenotebook

