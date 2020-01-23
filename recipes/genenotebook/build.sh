#!/bin/bash

set -exo pipefail

# sudo yum install libstdc++

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p $outdir $PREFIX/bin
pwd
ls -lah .

npm install --unsafe-perm
ls -lah .
# ls -lah /usr/lib64/libstdc*
# strings /usr/lib64/libstdc* | grep GLIBC

METEOR_PATH=$(readlink -f /root/.meteor/packages/meteor-tool/1.9.0)

METEOR_NODE_PATH=$(find $METEOR_PATH -name node | grep dev_bundle/bin)
NODE_PATH=$(which node)


#find $METEOR_PATH -name node -type f | xargs -n 1 -P 1 -I % sh -c \
#    "echo %; mv % %.bak; ln -s $NODE_PATH %"

echo $METEOR_NODE_PATH
echo $NODE_PATH

mv $METEOR_NODE_PATH $METEOR_NODE_PATH.bak
ln -s $NODE_PATH $METEOR_NODE_PATH

METEOR_NPM_PATH=$(find $METEOR_PATH -name npm | grep dev_bundle/bin)
NPM_PATH=$(which npm)

echo $METEOR_NPM_PATH
echo $NPM_PATH

mv $METEOR_NPM_PATH $METEOR_NPM_PATH.bak
ln -s $NPM_PATH $METEOR_NPM_PATH

npm install -g node-gyp

node /root/.meteor/packages/meteor-tool/.1.9.0.1mtsmz6.qnno++os.linux.x86_64+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/lib/node_modules/fibers/build

#ls -lah /root/.meteor/packages/meteor-tool/.1.9.0.1mtsmz6.qnno++os.linux.x86_64+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/bin/

meteor node -v

METEOR_ALLOW_SUPERUSER=1 METEOR_DISABLE_OPTIMISTIC_CACHING=1 npm run bundle

cp -R genenotebook_v${PKG_VERSION}/* $outdir

ln -s ${outdir}/genenotebook ${PREFIX}/bin/genenotebook

