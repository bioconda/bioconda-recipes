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
      ############################
      # TODO move the following into the if statement below before merging
      # fetch all branches
      git remote set-branches origin '*'
      git fetch
      git checkout origin/testall
      # calculate time since last testall run
      last=`git log -1 --format=%at`
      now=`date +%s`
      hours=`date -u -d "0 $now seconds - $last seconds" +%H`
      if [[ $hours -ge 20 ]]
      # if [[ $hours -ge 168 ]] # TODO replace above with this line
      then
        # trigger testall run
        git merge -X theirs origin/test-all
        git commit -a
        git push
      fi
      ############################
      if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
      then
        # push to testall branch to trigger tests of all recipes
        #git push --force --quiet "https://${GITHUB_TOKEN}@github.com/$TRAVIS_REPO_SLUG.git" master:testall > /dev/null 2>&1
        # build package documentation
        ./scripts/build-docs.sh
      fi
    fi
else
    export PATH=/anaconda/bin:$PATH
    # build packages
    scripts/build-packages.py --repository . $testonly
fi
