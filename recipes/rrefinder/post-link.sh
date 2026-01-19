#!/usr/bin/env bash

cat >> "${PREFIX}"/.messages.txt <<- EOF

##########################################################################################
Please add the missing dependency psipred (>=4.01) with:
conda install -c biocore psipred
##########################################################################################
EOF
