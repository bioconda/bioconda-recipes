#!/bin/sh
set -x -e

# build the db with BuildDatabase
BuildDatabase -name db test.fa

# run repeat modeler
RepeatModeler -database db

# check the result
test -s RM_*/consensi.fa
