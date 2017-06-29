#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
This package installs only the variant effect predictor (VEP) library
code. To install data libraries, you can use the 'vep_install.pl' command
installed along with it. For example, to install the VEP library for human
hg19/GRCh37 to a directory:

vep_install.pl -a cf -s homo_sapiens -y GRCh37 -c /output/path/to/hg19/vep
vep_convert_cache.pl -species homo_sapiens -version 86_GRCh37 -d /output/path/to/hg19/vep

(note that vep_install.pl is renamed from INSTALL.pl
 and vep_convert_cache.pl from covert_cache.pl
 to avoid having generic script names in the PATH)

The convert cache step is not required but improves lookup speeds during
runs. See the VEP documentation for more details:

http://useast.ensembl.org/info/docs/tools/vep/script/vep_cache.html
EOF
