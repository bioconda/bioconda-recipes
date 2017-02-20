export LC_CTYPE=C
export LANG=C

cd $SRC_DIR/src
export KMER=$PREFIX
sed -i.bak 's/$(LOCAL_OS)/$(PREFIX)/' c_make.gen
make
cd ../
sed -i.bak 's/getBinDirectory()/`which gatekeeper`/' ${PREFIX}/bin/runCA
sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g' ${PREFIX}/bin/runCA
