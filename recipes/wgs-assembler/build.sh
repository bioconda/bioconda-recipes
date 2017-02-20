export LC_CTYPE=C
export LANG=C

#find . -type f -name "*.pm" | xargs sed -i.bak -e 's/usr\/local\/bin\/perl/usr\/bin\/env perl/g'
#find . -type f -name "*.sh" | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

#cd $SRC_DIR/kmer
#./configure.sh

#export INCLUDE_PATH="${PREFIX}/include"
#export LIBRARY_PATH="${PREFIX}/lib"
#export LD_LIBRARY_PATH="${PREFIX}/lib"
#export LDFLAGS="-L${PREFIX}/lib"
#export CPPFLAGS="-I${PREFIX}/include"
#make install prefix=$PREFIX
cd $SRC_DIR/src

export KMER=$PREFIX
sed -i.bak 's/$(LOCAL_OS)/$(PREFIX)/' c_make.gen
sed -i.bak 's/getBinDirectory()/`which gatekeeper`/' AS_RUN/runCA.pl
sed -i.bak 's/usr\/local\/bin\/perl/usr\/bin\/env perl/g' AS_RUN/runCA.pl
make
cd ../
#ls Linux-amd64/

#mkdir -p $PREFIX/bin
#if [ `uname` == Darwin ]; then
#    mv Darwin-amd64/bin/* $PREFIX/bin/
#    mv Darwin-amd64/lib/* $PREFIX/lib/
#else
#    mv Linux-amd64/bin/* $PREFIX/bin/
#    mv Linux-amd64/lib/* $PREFIX/lib/
#fi
