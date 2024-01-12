#!/bin/bash

SCRIPTS="kreport2mpa.py combine_mpa.py combine_kreports.py extract_kraken_reads.py filter_bracken.out.py fix_unmapped.py kreport2krona.py make_kreport.py make_ktaxonomy.py"

for script in $SCRIPTS ; do 
  cp $script ${PREFIX}/bin
  chmod 755 ${PREFIX}/bin/$script
done

cp DiversityTools/alpha_diversity.py ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/alpha_diversity.py
cp DiversityTools/beta_diversity.py  ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/alpha_diversity.py
