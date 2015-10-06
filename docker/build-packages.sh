#!/bin/bash

# count errors
errors=0

# iterate over all recipes
for p in /tmp/conda-recipes/recipes/*
do
    # build package
    conda build --no-anaconda-upload --skip-existing $p || errors=$((errors + 1))
done
# upload all successfully built packages
anaconda -t $ANACONDA_TOKEN upload /tmp/conda-build/anaconda/conda-bld/linux-64/*.tar.bz2

# check for build or test errors and return proper exit code
[ $errors -eq 0 ]
exit $?
