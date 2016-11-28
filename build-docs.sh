#!/bin/bash

set -eou pipefail

# This setup uses a unique ssh keypair where the private key has been encoded
# via travis encrypt-file.
#
# References:
#  - https://docs.travis-ci.com/user/encrypting-files
#  - https://gist.github.com/domenic/ec8b0fc8ab45f39403dd

# Build docs only if travis-ci is testing this branch:
BUILD_DOCS_FROM_BRANCH="master"

# Stop early (and descriptively)
if [[ $TRAVIS_BRANCH != $BUILD_DOCS_FROM_BRANCH ]]; then
    echo "Not building docs because not on branch '$BUILD_DOCS_FROM_BRANCH'"
    exit 0
fi
if [[ $TRAVIS_PULL_REQUEST == "true" ]]; then
    echo "This is a pull request, so not building docs"
    exit 0
fi
if [[ $TRAVIS_OS_NAME != "linux" ]]; then
    echo "OS is not linux, so not building docs"
    exit 0
fi

# To push to bioconda.github.io instead, use:
# BRANCH="master"
# ORIGIN="bioconda.github.io"
BRANCH="gh-pages"
ORIGIN="bioconda-utils"

GITHUB_USERNAME="bioconda"
SSH_REPO="git@github.com:${GITHUB_USERNAME}/${ORIGIN}.git"
SHA=$(git rev-parse --verify HEAD)
HERE=$(pwd)

# These are specific to how sphinx-quickstart was set up
DOCSOURCE=${HERE}/docs
DOCHTML=${HERE}/docs/build/html

# tmpdir to which built docs will be copied
STAGING=/tmp/bioconda-docs

# decrypt and ssh-add key
ENCRYPTED_FILE=${HERE}/docs/key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in $ENCRYPTED_FILE -out key -d
chmod 600 key
eval `ssh-agent -s`
ssh-add key

# clone the branch to tmpdir, clean out contents
rm -rf $STAGING
mkdir -p $STAGING
git clone $SSH_REPO $STAGING
cd $STAGING
git checkout $BRANCH || git checkout --orphan $BRANCH
rm -r *

# build docs and copy over to tmpdir
cd ${DOCSOURCE}
make html
cp -r ${DOCHTML}/* $STAGING

# commit and push
cd $STAGING
touch .nojekyll
git add .nojekyll
echo ".*" >> .gitignore
git add .
git config user.name "Travis CI"
git config user.email " bioconda@users.noreply.github.com"
git commit --all -m "Updated docs to commit ${SHA}."
echo "Pushing to $SSH_REPO:$BRANCH"
git push $SSH_REPO $BRANCH &> /dev/null
