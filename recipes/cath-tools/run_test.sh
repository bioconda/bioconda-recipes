#!/bin/sh
set -x -e

# go in the original cath-tools folder
cd ${PREFIX}/share/cath-tools

#execute the test
build-test
