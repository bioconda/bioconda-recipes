#!/bin/bash

mkdir -p "$PREFIX/bin"
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' count-kmer-abundances.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env pythonl|g' est_abundance.py
sed -i.bak '1 s|^.*$|#!/usr/bin/env python|g' generate_kmer_distribution.py

cp count-kmer-abundances.pl est_abundance.py generate_kmer_distribution.py $PREFIX/bin
chmod +x $PREFIX/bin/count-kmer-abundances.pl
