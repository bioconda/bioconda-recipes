export LC_CTYPE=C
export LANG=C

cd $SRC_DIR/src
export KMER=$PREFIX
sed -i.bak 's/$(LOCAL_OS)/$(PREFIX)/' c_make.gen
make
cd ../
sed -i.bak "s/FileHandle;$/&\\nuse File::Basename;/" ${PREFIX}/bin/runCA
sed -i.bak 's/getBinDirectory()/dirname(__FILE__)/' ${PREFIX}/bin/runCA
sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g' ${PREFIX}/bin/runCA
