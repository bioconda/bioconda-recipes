#!/usr/bin/env bash
set -euo pipefail

picard --version
turbo-picard AccelerationStatus
picard MarkDuplicates --help

cat > input.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:1000
read-a	0	chr1	1	60	8M	*	0	0	ACGTACGT	FFFFFFFF
read-b	0	chr1	1	60	8M	*	0	0	ACGTACGT	FFFFFFFF
SAM

picard MarkDuplicates \
  I=input.sam \
  O=marked.sam \
  M=metrics.txt \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s marked.sam
test -s metrics.txt
grep -q 'UNPAIRED_READ_DUPLICATES' metrics.txt

picard ViewSam \
  I=marked.sam \
  O=view.sam \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s view.sam
grep -q '^read-a' view.sam
