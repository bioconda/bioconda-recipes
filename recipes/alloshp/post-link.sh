#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
This package installs AlloSHP. It ships with sample data so you can test it
as follows:

    $ make -f ${CONDA_PREFIX}/Makefile test_conda

The complete documentation can be found at:

https://github.com/eead-csic-compbio/AlloSHP

EOF
