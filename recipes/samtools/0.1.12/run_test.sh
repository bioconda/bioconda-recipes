#!/bin/sh

samtools faidx ex1.fa seq1

wgsim ex1.fa out.r1.fq out.r2.fq
