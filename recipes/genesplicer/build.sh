target=$PREFIX/share/
mkdir -p $target
mkdir -p $PREFIX/bin

mv * $target && cd $target
rm -rf bin
cd sources/ && make && cp genesplicer $PREFIX/bin
