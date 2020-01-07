#!/bin/sh
set -x -e

# build the db with BuildDatabase
BuildDatabase -engine ncbi -name db test.fa 2> /dev/null

# run repeat modeler
RepeatModeler -engine ncbi -database db 2> /dev/null

# check the result
test -s RM_*/consensi.fa
