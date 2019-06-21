#!/bin/sh
mkdir -p $PREFIX/bin

cp pgcgap.pl $PREFIX/bin/pgcgap
cp Functions/Pan/plot_3Dpie.R $PREFIX/bin/
cp Functions/Pan/fmplot.py $PREFIX/bin/

cp Functions/COG/COG.pl $PREFIX/bin/
cp Functions/COG/get_flag_relative_abundances_table.pl $PREFIX/bin/
cp Functions/COG/Plot_COG.R $PREFIX/bin/
cp Functions/COG/Plot_COG_Abundance.R $PREFIX/bin/

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
chmod a+x $PREFIX/bin/Plot_COG_Abundance.R
pgcgap --version
