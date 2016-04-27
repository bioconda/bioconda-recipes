#!/bin/bash
set -euo pipefail

if [[ $TRAVIS_BRANCH = "testall" ]]
then
  testonly="--testonly"
else
  testonly=""
fi

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    # run CentOS5 based docker container
    docker run -e SUBDAG -e SUBDAGS -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN -v `pwd`:/bioconda-recipes bioconda/bioconda-builder $testonly

    if [[ $SUBDAG = 0 ]]
    then
      # push to testall branch to trigger global tests (TODO replace test-all with master)
      if [[ $TRAVIS_BRANCH = "test-all" ]]
      then
        git push --force --quiet "https://${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/bioconda-recipes.git" test-all:testall > /dev/null 2>&1
      fi

      # Build package documentation
      ./scripts/build-docs.sh
    fi
else
    export PATH=/anaconda/bin:$PATH
    # build packages
    scripts/build-packages.py --repository . $testonly
fi
