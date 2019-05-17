#!/bin/sh

mkdir -p $PREFIX/bin

wget -c -r -nH -np -nd -R index.html -P ./ ftp://ftp.ncbi.nih.gov/pub/COG/COG2014/data/
gunzip prot2003-2014.fa.gz
makeblastdb -parse_seqids -in prot2003-2014.fa -input_type fasta -dbtype prot -out COG_2014
mv COG_2014.phr $PREFIX/bin/
mv COG_2014.pin $PREFIX/bin/
mv COG_2014.psq $PREFIX/bin/
mv cog2003-2014.csv $PREFIX/bin/
mv cognames2003-2014.tab $PREFIX/bin/
mv fun2003-2014.tab $PREFIX/bin/

cp pgcgap.pl $PREFIX/bin/pgcgap
cp Functions/Pan/plot_3Dpie.R $PREFIX/bin/
cp Functions/Pan/fmplot.py $PREFIX/bin/

cp Functions/COG/COG.pl $PREFIX/bin/
cp Functions/COG/get_flag_relative_abundances_table.pl $PREFIX/bin/
cp Functions/COG/Plot_COG.R $PREFIX/bin/

cp Functions/ANI/get_ANImatrix.pl $PREFIX/bin/
cp Functions/ANI/Plot_ANIheatmap.R $PREFIX/bin/



chmod a+x $PREFIX/bin/pgcgap
chmod a+x $PREFIX/bin/plot_3Dpie.R
chmod a+x $PREFIX/bin/fmplot.py
chmod a+x $PREFIX/bin/COG.pl
chmod a+x $PREFIX/bin/get_flag_relative_abundances_table.pl
chmod a+x $PREFIX/bin/Plot_COG.R
chmod a+x $PREFIX/bin/get_ANImatrix.pl
chmod a+x $PREFIX/bin/Plot_ANIheatmap.R
chmod a+r $PREFIX/bin/COG_2014.phr
chmod a+r $PREFIX/bin/COG_2014.pin
chmod a+r $PREFIX/bin/COG_2014.psq
chmod a+r $PREFIX/bin/cog2003-2014.csv
chmod a+r $PREFIX/bin/cognames2003-2014.tab
chmod a+r $PREFIX/bin/fun2003-2014.tab


pgcgap --version

pgcgap --help

pgcgap --check-external-programs
