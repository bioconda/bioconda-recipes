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
      if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
      then
        # push to testall branch to trigger tests of all recipes
        git push --force --quiet "https://${GITHUB_TOKEN}@github.com/$TRAVIS_REPO_SLUG.git" master:testall > /dev/null 2>&1
        # build package documentation
        ./scripts/build-docs.sh
      fi
    fi
else
    export PATH=/anaconda/bin:$PATH
    # build packages
    scripts/build-packages.py --repository . $testonly
fi
