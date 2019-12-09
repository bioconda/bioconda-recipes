#!/bin/sh
set -x -e

# build the db with BuildDatabase
BuildDatabase -engine ncbi -name db test.fa 2> /dev/null

# run repeat modeler
RepeatModeler -engine ncbi -database db 2> /dev/null

# check the result
if [ -s RM_*/consensi.fa ] ; then 
  exit 0 # it is fine
else
  exit 1 # return error
fi 
