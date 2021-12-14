#!/bin/bash

mkdir -p ${PREFIX}/bin/

cp *.py  ${PREFIX}/bin/
cp -r utils/*.py ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/main.py
chmod +x ${PREFIX}/bin/mtglink.py
chmod +x ${PREFIX}/bin/helpers.py
chmod +x ${PREFIX}/bin/Pipeline.py
chmod +x ${PREFIX}/bin/ReadSubsampling.py
chmod +x ${PREFIX}/bin/DBG.py
chmod +x ${PREFIX}/bin/IRO.py
chmod +x ${PREFIX}/bin/ProgDynOptim.py
chmod +x ${PREFIX}/bin/QualEval.py
chmod +x ${PREFIX}/bin/stats_alignment.py
chmod +x ${PREFIX}/bin/paths2gfa.py
chmod +x ${PREFIX}/bin/gfa2_to_gfa1.py
chmod +x ${PREFIX}/bin/gfa2fasta.py
chmod +x ${PREFIX}/bin/gfa2_to_fasta.py
chmod +x ${PREFIX}/bin/matrix2gfa.py
chmod +x ${PREFIX}/bin/mergegfa.py
chmod +x ${PREFIX}/bin/fasta2bed.py
chmod +x ${PREFIX}/bin/bed2gfa.py

