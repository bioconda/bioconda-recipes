#!/usr/bin/env bash

gcc -lz -o readfq kseq_fastq_base.c
cp readfq $PREFIX/bin/readfq
