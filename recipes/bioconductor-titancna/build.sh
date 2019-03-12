#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .

# TitanCNA wrapper scripts and data
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir/scripts/R_scripts
mkdir -p $outdir/data
mkdir -p $PREFIX/bin

perl -pi -e 'print "#!/opt/anaconda1anaconda2anaconda3/bin/Rscript\n" if $. == 1' scripts/R_scripts/selectSolution.R
sed -i.bak 's:/usr/bin/env Rscript:/opt/anaconda1anaconda2anaconda3/bin/Rscript:' scripts/R_scripts/titanCNA.R

mv scripts/R_scripts/selectSolution.R $outdir/scripts/R_scripts/titanCNA_selectSolution.R
mv scripts/R_scripts/titanCNA.R $outdir/scripts/R_scripts/titanCNA.R

chmod a+x $outdir/scripts/R_scripts/*.R
ln -s $outdir/scripts/R_scripts/titanCNA.R $PREFIX/bin
ln -s $outdir/scripts/R_scripts/titanCNA_selectSolution.R $PREFIX/bin
-
# Retrieve external data we want to link into the run
wget --no-check-certificate -O $outdir/data/cytoBand_hg38.txt https://raw.githubusercontent.com/broadinstitute/ichorCNA/master/inst/extdata/cytoBand_hg38.txt
