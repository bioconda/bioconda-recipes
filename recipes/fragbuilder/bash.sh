#!/bin/env bash
wget https://codeload.github.com/jensengroup/fragbuilder/tar.gz/1.0.1

tar xvzf fragbuilder-1.0.1.tar.gz

# setup environment variables
export PYTHONPATH=${PREFIX}/lib/python2.7/site-packages:${PYTHONPATH}

cp -r fragbuilder-1.0.1/fragbuilder ${PREFIX}/lib/python2.7/site-packages





