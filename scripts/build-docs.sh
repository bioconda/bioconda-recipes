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
rm -rf bioconda.github.io
git clone https://github.com/${GITHUB_USERNAME}/bioconda.github.io.git
rm -rf bioconda.github.io
mkdir -p bioconda.github.io
sphinx-build . bioconda.github.io

# Add generated files to the bioconda.github.io repository
cd bioconda.github.io
echo '.*' >> .gitignore
git add .
git -c user.name='travis' -c user.email='travis' commit --all -m "Updated docs to commit ${TRAVIS_COMMIT}."
git push -f -q "https://${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/bioconda.github.io.git" master

# Cleanup
cd ..
rm -rf bioconda.github.io
