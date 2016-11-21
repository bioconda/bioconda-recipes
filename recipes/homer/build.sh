#! /bin/bash


outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $PREFIX/bin
chmod +x configureHomer.pl
cp configureHomer.pl $outdir/

perl $outdir/configureHomer.pl -install

# Note that homer cannot be built as a package since the installation
# script *hard-codes* the paths in the perl scripts. Nevertheless,
# create symlinks to $outdir/bin as this is where configureHomer.pl
# -install will put the binaries

# For all binaries, wrap configureHomer.pl; not the ideal way to go
ls -1 $outdir/bin/ | grep -v old | sed -e "s/\*/ \\\/g" | while read id;
do
    chmod +x $outdir/bin/$id;
    ln -s $outdir/bin/$id $PREFIX/bin/$id;
done

chmod +x $outdir/configureHomer.pl
ln -s $outdir/configureHomer.pl $PREFIX/bin/configureHomer.pl 

# Add helper script to configureHomer.pl so that configureHomer.pl
# -install really installs in $outdir
#configureHomer=$PREFIX/bin/configureHomer.pl
#echo "#! /bin/bash" > $configureHomer;
#echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $configureHomer;
#echo '$DIR/../share/'$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/configureHomer.pl '$@' >> $configureHomer;
#chmod +x $configureHomer;

