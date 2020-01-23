#!/bin/bash

set -exo pipefail

sudo apt-get install libstdc++6 || sudo yum install libstdc++6

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p $outdir $PREFIX/bin
pwd
ls -lah .

npm install --unsafe-perm
ls -lah /usr/lib64/libstdc*
strings /usr/lib64/libstdc* | grep GLIBC
METEOR_ALLOW_SUPERUSER=1 METEOR_DISABLE_OPTIMISTIC_CACHING=1 npm run bundle

cp -R genenotebook_v${PKG_VERSION}/* $outdir

ln -s ${outdir}/genenotebook ${PREFIX}/bin/genenotebook

