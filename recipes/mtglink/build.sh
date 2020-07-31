#!/bin/bash

mkdir -p ${PREFIX}/bin/

cp *.py  ${PREFIX}/bin/
cp -r utils/*.py ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/mtglink.py
chmod +x ${PREFIX}/bin/stats_alignment.py
chmod +x ${PREFIX}/bin/paths2gfa.py
chmod +x ${PREFIX}/bin/gfa2_to_gfa1.py
chmod +x ${PREFIX}/bin/gfa2fasta.py
chmod +x ${PREFIX}/bin/fasta2gfa.py


