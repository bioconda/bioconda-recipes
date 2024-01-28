#!/bin/bash

set -x -e

# adapted from recipes/blast/run_test.sh

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp test.tre $TMPDIR
cd $TMPDIR

astral -i test.tre

