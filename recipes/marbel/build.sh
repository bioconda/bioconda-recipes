#!/bin/bash

# install custom modify dependency, not recommended but too avoid cluttering bioconda package enviornment
# we asked for advice from bioconda team and they suggested to use this approach
# rename the package to avoid namespace conflict wiht existing package
# not vendored in our package to keep code base cleab

cd marbeldep
$PYTHON -m pip install . --no-deps --ignore-installed -vv
cd ..

$PYTHON -m pip install . --no-deps --ignore-installed -vv