#!/bin/sh
set -x -e

# build the db with BuildDatabase
# BuildDatabase -engine rmblast -name db test.fa

# run repeat modeler
# RepeatModeler -engine rmblast -database db

# check the result
# test -s RM_*/consensi.fa

# RepeatModeler 2.0.4 depends on the "setThreadByQuery" module in NCBIBlastSearchEngine.pm of RepeatMasker versions >=4.1.4
"RepeatModeler -h | grep SYNOPSIS"
