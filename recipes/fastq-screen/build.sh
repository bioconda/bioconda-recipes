#!/bin/bash
mkdir -p $PREFIX/bin
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' fastq_screen
cp fastq_screen $PREFIX/bin/fastq_screen
chmod +x $PREFIX/bin/fastq_screen
