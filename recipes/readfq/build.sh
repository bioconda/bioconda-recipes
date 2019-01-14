#!/usr/bin/env bash

${CC} -lz -o readfq kseq_fastq_base.c
cp readfq $PREFIX/bin/readfq
