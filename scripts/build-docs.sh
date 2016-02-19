#!/bin/bash

set -ev

if ! [[ "${TRAVIS_BRANCH}" == "master" && "${TRAVIS_PULL_REQUEST}" == "false" ]] ; then
    echo "Not on master so not building docs."
    exit 0
fi

if [[ -z "${GITHUB_TOKEN}" ]] ; then
    echo "GitHub API key needs to be set to update docs."
    exit 0
fi

cd "${TRAVIS_BUILD_DIR}/docs"

# Install sphinx requirements
sudo pip install -U pip
sudo pip install -r requirements.txt

# Build the documentation
GITHUB_USERNAME=${TRAVIS_REPO_SLUG%/*}
mkdir -p bioconda.github.io
cd bioconda.github.io
git init
sphinx-build .. .

# Add generated files to the bioconda.github.io repository
touch .nojekyll
git add .nojekyll
echo '.*' >> .gitignore
git add .
git config user.name "Travis CI"
git commit --all -m "Updated docs to commit ${TRAVIS_COMMIT}."
git push -f -q "https://${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/bioconda.github.io.git" master &> /dev/null

# Cleanup
cd ..
rm -rf bioconda.github.io
