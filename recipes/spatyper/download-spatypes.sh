#! /bin/bash
OUTPUT_PATH="${1:-$SPATYPER_SHARE}"

echo "Downloading spa types to ${OUTPUT_PATH}"
wget -O ${OUTPUT_PATH}/sparepeats.fasta http://spa.ridom.de/dynamic/sparepeats.fasta
wget -O ${OUTPUT_PATH}/spatypes.txt http://spa.ridom.de/dynamic/spatypes.txt
