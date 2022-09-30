#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
cp pavfinder/scripts/* ${PREFIX}/bin/

chmod 0755 "${PREFIX}/bin/check_support.py"
chmod 0755 "${PREFIX}/bin/extract_transcript_sequence.py"
chmod 0755 "${PREFIX}/bin/filter_fasta"
chmod 0755 "${PREFIX}/bin/filter_fasta.py"
chmod 0755 "${PREFIX}/bin/find_sv_genome.py"
chmod 0755 "${PREFIX}/bin/find_sv_transcriptome.py"
chmod 0755 "${PREFIX}/bin/fusion-bloom"
chmod 0755 "${PREFIX}/bin/link_ssv.py"
chmod 0755 "${PREFIX}/bin/map_splice.py"
chmod 0755 "${PREFIX}/bin/pavfinder"
chmod 0755 "${PREFIX}/bin/rescue_fusion.py"
chmod 0755 "${PREFIX}/bin/tap"
chmod 0755 "${PREFIX}/bin/tap2"

