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

extdata=$PREFIX/lib/R/library/PureCN/extdata
mkdir -p $PREFIX/bin
for f in Coverage.R Dx.R FilterCallableLoci.R IntervalFile.R NormalDB.R
do
    perl -pi -e 'print "#!/opt/anaconda1anaconda2anaconda3/bin/Rscript\n" if $. == 1' $extdata/$f
    ln -s $extdata/$S $PREFIX/bin/PureCN_${f}
done

perl -pi -e 'print "#!/opt/anaconda1anaconda2anaconda3/bin/Rscript\n" if $. == 1' $extdata/PureCN.R
ln -s $extdata/PureCN.R $PREFIX/bin/PureCN.R
