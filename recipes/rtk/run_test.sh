#!/bin/bash
# rtk tested on a small table

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp table.tsv $TMPDIR
cd $TMPDIR

rtk swap -i table.tsv -o table.out
echo PASS
