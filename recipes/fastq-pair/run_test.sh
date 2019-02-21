#!/bin/bash
set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp left.fastq right.fastq sha256sums $TMPDIR
cd $TMPDIR

fastq_pair left.fastq right.fastq
sha256sum -c sha256sums
