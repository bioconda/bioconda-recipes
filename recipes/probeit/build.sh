#!/bin/bash
conda install -c bioconda mmseqs2
conda install -c bioconda genmap
conda install -c bioconda seqkit
conda install -c bioconda primer3
conda install -c bioconda primer3-py
cd setcover
make
cd ..
