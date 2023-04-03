#!/bin/sh
set -x -e

# build the db with BuildDatabase
BuildDatabase -engine rmblast -name db test.fa

# run repeat modeler
RepeatModeler -engine rmblast -database db

# check the result
test -s RM_*/consensi.fa
