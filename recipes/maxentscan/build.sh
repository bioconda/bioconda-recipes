target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

# add perl shebang
sed -i.bak "1i #!/usr/bin/env perl" *.pl

#change hardcoded directory of splicemodels
sed -i.bak "s@\"splicemodels/\"@\"$target/splicemodels/\"@" score3.pl
sed -i.bak "s@'me2x5'@'$target/me2x5'@" score5.pl
sed -i.bak "s@'splicemodels/splice5sequences'@'$target/splicemodels/splice5sequences'@" score5.pl

cp score3.pl $target/maxentscan_score3.pl
cp score5.pl $target/maxentscan_score5.pl
cp -r splicemodels $target
cp me2x5 $target/me2x5

chmod 0755 $target/*.pl
ln -s $target/*.pl $PREFIX/bin


