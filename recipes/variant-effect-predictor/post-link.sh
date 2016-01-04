#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
This package installs only the variant effect predictor (VEP) library
code. To install data libraries, you can use the 'vep_install.pl' command
installed along with it. For example, to install the VEP library for human
hg19/GRCh37 to a directory:

vep_install.pl -a c -s homo_sapiens_vep_83_GRCh37 -c /output/path/to/hg19/vep
vep_convert_cache.pl -species home_sapiens -version 83_GRCh37 -d /output/path/to/hg19/vep

The convert cache step is not required but improves lookup speeds during
runs. See the VEP documentation for more details:

http://useast.ensembl.org/info/docs/tools/vep/script/vep_cache.html
EOF
