#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
This package installs only the variant effect predictor (VEP) library
code. To install data libraries, you can use the 'vep_install' command
installed along with it. For example, to install the VEP library for human
GRCh38 to a directory

vep_install -a cf -s homo_sapiens -y GRCh38 -c /output/path/to/GRCh38/vep --CONVERT

(note that vep_install is renamed from INSTALL.pl
 to avoid having generic script names in the PATH)

The --CONVERT flag is not required but improves lookup speeds during
runs. See the VEP documentation for more details

http://www.ensembl.org/info/docs/tools/vep/script/vep_cache.html
EOF
