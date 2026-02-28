#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt


antiSMASH databases are no longer included in the antismash conda package due to a "no space left on device" error.
Before using antiSMASH, please download the databases required by several options:
download-antismash-databases


EOF
