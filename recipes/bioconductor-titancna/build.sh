#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir/scripts/R_scripts
mkdir -p $PREFIX/bin

perl -pi -e 'print "#!/opt/anaconda1anaconda2anaconda3/bin/Rscript\n" if $. == 1' scripts/R_scripts/selectSolution.R
sed -i.bak 's:/usr/bin/env Rscript:/opt/anaconda1anaconda2anaconda3/bin/Rscript:' scripts/R_scripts/titanCNA.R

mv scripts/R_scripts/selectSolution.R $outdir/scripts/R_scripts/titanCNA_selectSolution.R
mv scripts/R_scripts/titanCNA.R $outdir/scripts/R_scripts/titanCNA.R

chmod a+x $outdir/scripts/R_scripts/*.R
ln -s $outdir/scripts/R_scripts/titanCNA.R $PREFIX/bin
ln -s $outdir/scripts/R_scripts/titanCNA_selectSolution.R $PREFIX/bin
