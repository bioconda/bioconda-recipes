#!/bin/bash

cat >> "$PREFIX/.messages.txt" <<EOF

As of Medaka v1.8.2, Oxford Nanopore Technologies no longer supports Bioconda
packages of Medaka. Issues related to the Bioconda package should be reported
to the bioconda-recipes repository. Otherwise, please see the Medaka repository
on GitHub for alternative installation methods supported by Oxford Nanopore
Technologies.

EOF
exit 0
