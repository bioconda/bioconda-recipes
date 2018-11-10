#!/bin/bash
set -euo pipefail

echo -e '' > test.bam
echo -e '##fileformat=VCFv4.1' > test.vcf
echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\ttumor\tnormal' >> test.vcf
break-point-inspector -tumor test.bam -ref test.bam -vcf test.vcf > /dev/null