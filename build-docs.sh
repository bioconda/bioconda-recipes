#!/bin/bash

# Build docs here, then copy them over to a fresh, temporary checkout of the
# gh-pages branch from github. Then upload 'em.

# Ideas from:
# http://executableopinions.readthedocs.org/en/latest/labs/gh-pages/gh-pages.html
set -e
set -x

REPO=$(git remote -v | grep push | awk '{print $2}')
MAKEFILE=docs/Makefile
(cd $(dirname $MAKEFILE) && make html)
HERE=$(pwd)
DOCSOURCE=$HERE/docs/build/html
MSG="Adding gh-pages docs for $(git log --abbrev-commit | head -n1)"
TMPREPO=/tmp/docs
rm -rf $TMPREPO
mkdir -p -m 0755 $TMPREPO
git clone $REPO $TMPREPO
cd $TMPREPO
git checkout gh-pages
cp -r $DOCSOURCE/* $TMPREPO
touch $TMPREPO/.nojekyll
git add -A
git commit -m "$MSG"
git push origin gh-pages
cd $HERE
