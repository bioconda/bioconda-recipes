#!/bin/bash
set -eu -o pipefail


$PYTHON setup.py install --single-version-externally-managed --record=record.txt

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/ORFfinder/linux-i64/ORFfinder.gz

gunzip ORFfinder.gz

chmod +x ORFfinder

mv ORFfinder ${PREFIX}/bin/
