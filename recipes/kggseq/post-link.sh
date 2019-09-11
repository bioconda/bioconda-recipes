#!/bin/bash

# call gatk-register which will print its usage statement
#$PREFIX/bin/gatk-register
#
## exit 0 so the install is a success
#exit 0
echo "potrebbe anche funzionare"
kggseq --lib-update
wget "grass.cgs.hku.hk/limx/kggseq/download/kggseqhg19min.zip"