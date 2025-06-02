#!/bin/bash
set -e
set -o pipefail
set -x

# Tests est-sfs on its example dataset

TMP=$(mktemp -d)
cd $TMP
wget https://sourceforge.net/projects/est-usfs/files/est-sfs-release-2.04.tar.gz
tar -xvf est-sfs-release-2.04.tar.gz
cd est-sfs-release-2.04
est-sfs config-kimura.txt TEST-DATA.TXT seedfile.txt output-file-sfs.txt output-file-pvalues.txt
