#!/bin/bash

# count errors
errors=""

# iterate over all recipes
for p in /tmp/conda-recipes/recipes/*
do
    # build package
    conda build --no-anaconda-upload --skip-existing $p || errors+=$p"\n"
done

# if testing master branch
if [[ $TRAVIS_BRANCH = "master" && $TRAVIS_PULL_REQUEST = "false" ]]
then
    # upload all successfully built packages
    anaconda -t $ANACONDA_TOKEN upload /tmp/conda-build/anaconda/conda-bld/linux-64/*.tar.bz2
fi

# check for build or test errors and return proper exit code
if [[ -n $errors ]]
then
    echo FAILED BUILDS:
    echo -e $errors
    exit 1
else
    exit 0
fi
