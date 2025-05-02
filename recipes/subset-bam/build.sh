#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

mv subset-bam_* ${PREFIX}/bin/subset-bam
chmod 755 ${PREFIX}/bin/subset-bam
