#!/bin/bash

mkdir -p ${PREFIX}/bin
chmod +x *.sh
cp {*.sh,*.pl,*.r} ${PREFIX}/bin

mkdir testdata
printf "chr21\t9415252\t9415288\BI:080403_SL-XAG_0003_FC208P5AAXX:6:174:599:803\t42\t+" > testdata/b.chr21.bed
printf "chr21\t9418045\t9418096\tFC305HLAAXX:2:16:424:1682\t40\t-" > testdata/b.chr21.bed
printf "chr21\t48129895" > chrSizes21.csize
./JAMM.sh -s testdata -g chrSizes21.csize -o jamm_out
ls jamm_out/peaks/all.peaks.narrowPeak # non-zero return if file not found
