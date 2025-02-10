#!/bin/bash

mkdir -p ${PREFIX}/bin/

cp *.py  ${PREFIX}/bin/
cp -r utils/*.py ${PREFIX}/bin/
cp -r test/*.py ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/main.py
chmod +x ${PREFIX}/bin/mtglink.py
chmod +x ${PREFIX}/bin/helpers.py
chmod +x ${PREFIX}/bin/gapFilling.py
chmod +x ${PREFIX}/bin/barcodesExtraction.py
chmod +x ${PREFIX}/bin/readsRetrieval.py
chmod +x ${PREFIX}/bin/localAssemblyDBG.py
chmod +x ${PREFIX}/bin/localAssemblyIRO.py
chmod +x ${PREFIX}/bin/ProgDynOptim.py
chmod +x ${PREFIX}/bin/qualitativeEvaluation.py
chmod +x ${PREFIX}/bin/stats_alignment.py
chmod +x ${PREFIX}/bin/fasta2bed.py
chmod +x ${PREFIX}/bin/bed2gfa.py
chmod +x ${PREFIX}/bin/paths2gfa.py
chmod +x ${PREFIX}/bin/matrix2gfa.py
chmod +x ${PREFIX}/bin/vcf2gfa.py
chmod +x ${PREFIX}/bin/mergegfa.py
chmod +x ${PREFIX}/bin/gfa2tofasta.py
chmod +x ${PREFIX}/bin/gfa1tofasta.py
chmod +x ${PREFIX}/bin/test.py
