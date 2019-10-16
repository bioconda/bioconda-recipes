$R CMD INSTALL --build .

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir/scripts
mkdir -p $outdir/extdata
mkdir -p $PREFIX/bin

perl -pi -e 'print "#!/opt/anaconda1anaconda2anaconda3/bin/Rscript\n" if $. == 1' scripts/runIchorCNA.R
perl -pi -e 'print "#!/opt/anaconda1anaconda2anaconda3/bin/Rscript\n" if $. == 1' scripts/createPanelOfNormals.R

cp ./scripts/*.R $outdir/scripts/

echo "***************"
echo "* DEBUG START *"
echo "***************"

echo ""

echo $outdir
find $outdir
echo "-----"
pwd -P
find .

echo ""

echo "!!!!!"
echo ""

find $outdir

echo ""

echo "*************"
echo "* DEBUG END *"
echo "*************"



chmod a+x $outdir/scripts/*.R
ln -s $outdir/scripts/runIchorCNA.R $PREFIX/bin
ln -s $outdir/scripts/ichorCNA_createPanelOfNormals.R $PREFIX/bin

cp inst/extdata/* $outdir/extdata
