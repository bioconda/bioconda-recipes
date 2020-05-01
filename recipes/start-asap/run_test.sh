#!/bin/bash

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cd $TMPDIR
pwd

echo -n "[test start-asap installation]"
start-asap --version

echo -n "[test with empty files]"
mkdir -p start-asap-input
touch start-asap-input/sample1_R1.fq.gz
touch start-asap-input/sample1_R2.fq.gz
touch start-asap-input/sample2_R1.fq.gz
touch start-asap-input/sample2_R2.fq.gz
touch start-asap-input/sample3_R1.fq.gz
touch start-asap-input/sample4_R2.fq.gz
touch start-asap-input/control_R1.fq.gz
touch start-asap-input/control_R2.fq.gz
touch start-asap-input/e_coli.gbk
find start-asap-input
start-asap -i start-asap-input -o start-asap-test -r start-asap-input/e_coli.gbk -g Escherichia -s coli --verbose

find start-asap-test
ls start-asap-input/config.xls
