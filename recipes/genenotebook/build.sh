#!/bin/bash

set -exo pipefail

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p $outdir $PREFIX/bin
pwd
ls -lah .

git clone https://github.com/meteor/meteor
pushd meteor
git checkout 39cc07472f8f1dc820b29b8c5a30813051d62700 #V1.9.0 commit
#cat scripts/generate-dev-bundle.sh | sed 3,4d | sed 3s/.*/set\ \-eox/ | sed 95,102d | sed 89d | sed 85d | sed 51,52d | sed 50s/.*/mkdir\ -p\ bin\ lib\\/node_modules/ > scripts/gen_dev_bundle.sh && PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' sh scripts/gen_dev_bundle.sh

./scripts/build-node-for-dev-bundle.sh
./scripts/generate-dev-bundle.sh

sed -i.bak 2s/.*/set\ \-eox/ meteor

./meteor --get-ready
./meteor --version
export PATH=$(pwd):$PATH
popd

npm install --unsafe-perm
ls -lah .

#METEOR_PATH=$(readlink -f /root/.meteor/packages/meteor-tool/1.9.0)
#
#METEOR_NODE_PATH=$(find $METEOR_PATH -name node | grep dev_bundle/bin)
#NODE_PATH=$(which node)
#
#echo $METEOR_NODE_PATH
#echo $NODE_PATH
#
#mv $METEOR_NODE_PATH $METEOR_NODE_PATH.bak
#ln -s $NODE_PATH $METEOR_NODE_PATH
#
#METEOR_NPM_PATH=$(find $METEOR_PATH -name npm | grep dev_bundle/bin)
#NPM_PATH=$(which npm)
#
#echo $METEOR_NPM_PATH
#echo $NPM_PATH
#
#mv $METEOR_NPM_PATH $METEOR_NPM_PATH.bak
#ln -s $NPM_PATH $METEOR_NPM_PATH
#
#pushd /root/.meteor/packages/meteor-tool/.1.9.0.1mtsmz6.qnno++os.linux.x86_64#+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/lib/#node_modules/fibers/
#ls -lah 
#npm install --unsafe-perm
#popd
#
#PATHWATCHER_NODE_PATH=$(find $METEOR_PATH -name "*node" | grep pathwatcher | #grep -v obj.target)
#
#ls -lah $PATHWATCHER_NODE_PATH
#
#mv $PATHWATCHER_NODE_PATH $PATHWATCHER_NODE_PATH.bak
#ln -s $NODE_PATH $PATHWATCHER_NODE_PATH

#/root/.meteor/packages/meteor-tool/.1.9.0.1mtsmz6.qnno++os.linux.x86_64+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/lib/node_modules/pathwatcher/build/Release/pathwatcher.node

# yum install gcc-c++
# yum groupinstall 'Development Tools'

# npm install -g node-gyp

# node /root/.meteor/packages/meteor-tool/.1.9.0.1mtsmz6.qnno++os.linux.x86_64+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/lib/node_modules/fibers/build

# ls -lah /root/.meteor/packages/meteor-tool/.1.9.0.1mtsmz6.qnno++os.linux.x86_64+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/bin/

meteor node -v

METEOR_ALLOW_SUPERUSER=1 METEOR_DISABLE_OPTIMISTIC_CACHING=1 npm run bundle

cp -R genenotebook_v${PKG_VERSION}/* $outdir

ln -s ${outdir}/genenotebook ${PREFIX}/bin/genenotebook

