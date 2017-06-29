target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

#delete precompiled executables
rm -rf bin/
#compile new executable
cd sources/ && make
#move everything to target directory
cd ../
cp ./sources/genesplicer $target && rm -rf sources
cp -r * $target

chmod 0755 $target/*
ln -s $target/genesplicer $PREFIX/bin
