#!/bin/bash

echo Testing b2bTools

cat <<EOT >> input_example.fasta
>SEQ_1
MEDLNVVDSINGAGSWLVANQALLLSYAVNIVAALAIIIVGLIIARMISNAVNRLMISRK
IDATVADFLSALVRYGIIAFTLIAALGRVGVQTASVIAVLGAAGLAVGLALQGSLSNLAA
GVLLVMFRPFRAGEYVDLGGVAGTVLSVQIFSTTMRTADGKIIVIPNGKIIAGNIINFSR
EPVRRNEFIIGVAYDSDIDQVKQILTNIIQSEDRILKDREMTVRLNELGASSINFVVRVW
SNSGDLQNVYWDVLERIKREFDAAGISFPYPQMDVNFKRVKEDKAA
EOT

python -m b2bTools --help

python -m b2bTools -file ./input_example.fasta -identifier TEST -output ./results_b2b.json -dynamine -disomine -efoldmine -agmata

rm ./input_example.fasta

cat ./results_b2b.json

rm ./results_b2b.json

echo ""
echo Test finished