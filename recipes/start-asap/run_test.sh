#!/bin/bash

set -ex

TMPDIR=$(mktemp -d)
INPUT_DIR=start-asap-input-dir
OUTPUT_DIR=start-asap-output-dir
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cd $TMPDIR
pwd

echo "[test start-asap installation $PKG_VERSION]"
start-asap --version 2>&1 | grep $PKG_VERSION

echo "[test with empty files]"
mkdir -p "$INPUT_DIR"
touch "$INPUT_DIR"/sample1_R1.fq.gz
touch "$INPUT_DIR"/sample1_R2.fq.gz
touch "$INPUT_DIR"/sample2_R1.fq.gz
touch "$INPUT_DIR"/sample2_R2.fq.gz
touch "$INPUT_DIR"/sample3_R1.fq.gz
touch "$INPUT_DIR"/sample4_R2.fq.gz
touch "$INPUT_DIR"/control_R1.fq.gz
touch "$INPUT_DIR"/control_R2.fq.gz
touch "$INPUT_DIR"/e_coli.gbk
find "$INPUT_DIR"
start-asap -i "$INPUT_DIR" -o "$OUTPUT_DIR" -r "$INPUT_DIR"/e_coli.gbk -g Escherichia -s coli --verbose

# Produced config.xls
file "$OUTPUT_DIR"/config.xls

