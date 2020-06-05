#!/bin/bash

set -eou pipefail

# References:
#  - https://docs.travis-ci.com/user/encrypting-files
#  - https://gist.github.com/domenic/ec8b0fc8ab45f39403dd

# ----------------------------------------------------------------------------
#
# Repository-specific configuration
#
# ----------------------------------------------------------------------------

# Note that the keypair needs to be specific to repo, so if ORIGIN changes, the
# keypair (docs/key.enc, and the corresponding public key in the setting of the
# repo) need to be updated.
BRANCH="master"
ORIGIN="bioconda.github.io"
GITHUB_USERNAME="bioconda"

# DOCSOURCE is directory containing the Makefile, relative to the directory
# containing this bash script.
DOCSOURCE=`pwd`/docs

# DOCHTML is where sphinx is configured to save the output HTML
DOCHTML=$DOCSOURCE/build/html

# tmpdir to which built docs will be copied
STAGING=/tmp/${GITHUB_USERNAME}-docs

# Deploy docs only from this branch (i.e. on commit)
BUILD_DOCS_FROM_BRANCH="master"

# ----------------------------------------------------------------------------
#
# END repository-specific configuration. The code below is generic; to use for
# another repo, edit the above settings.
#
# ----------------------------------------------------------------------------

if [[ $CIRCLE_PROJECT_USERNAME != bioconda ]]; then
    # exit if not in bioconda repo
    exit 0
fi

REPO="git@github.com:${GITHUB_USERNAME}/${ORIGIN}.git"

# clone the branch to tmpdir, clean out contents
rm -rf $STAGING
mkdir -p $STAGING

SHA=$(git rev-parse --verify HEAD)
git clone $REPO $STAGING --depth=1
cd $STAGING
git checkout $BRANCH || git checkout --orphan $BRANCH
rm -r *

# build docs and copy over to tmpdir
cd ${DOCSOURCE}
# NOTE: With more build jobs (e.g., "-j8") the "Required By:" entries in the
#       package index do not work. DO NOT change "-j1" unless that gets fixed!
#       ref: https://github.com/bioconda/bioconda-utils/pull/658#issuecomment-639399930
make clean html SPHINXOPTS="-T -j1" 2>&1 | grep -v "WARNING: nonlocal image URL found:"
cp -r ${DOCHTML}/* $STAGING

# add README.md
cp $DOCSOURCE/README.md $STAGING

# add .nojekyll
touch $STAGING/.nojekyll


# committing with no changes results in exit 1, so check for that case first.
cd $STAGING
if git diff --quiet; then
    echo "No changes to push -- exiting cleanly"
    exit 0
fi

if [[ $CIRCLE_BRANCH != $BUILD_DOCS_FROM_BRANCH ]]; then
    echo "Not pushing docs because not on branch '$BUILD_DOCS_FROM_BRANCH'"
    exit 0
fi


# Add, commit, and push
echo ".*" >> .gitignore
git config user.name "{GITHUB_USERNAME}"
git config user.email "${GITHUB_USERNAME}@users.noreply.github.com"
git add -A .
git commit --all -m "Updated docs to commit ${SHA}."
echo "Pushing to $REPO:$BRANCH"
git push $REPO $BRANCH &> /dev/null
