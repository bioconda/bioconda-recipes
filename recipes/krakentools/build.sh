SCRIPTS="combine_kreports.py extract_kraken_reads.py filter_bracken.out.py fix_unmapped.py kreport2krona.py make_kreport.py make_ktaxonomy.py"

for script in $SCRIPTS ; do 
  cp $script ${PREFIX}/bin
  chmod 755 ${PREFIX}/bin/$script
done
