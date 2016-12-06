target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

#change hardcoded directory of splicemodels
sed -i.bak "s@\"splicemodels/\"@\"$target/splicemodels/\"@" *.pl

cp score3.pl $target/maxentscan_score3.pl
cp score5.pl $target/maxentscan_score5.pl
cp -r splicemodels $target

chmod 0755 $target/*.pl
ln -s $target/*.pl $PREFIX/bin


