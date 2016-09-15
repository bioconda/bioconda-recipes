mkdir -p $PREFIX/bin

cp  LINKS $PREFIX/bin
chmod +x $PREFIX/bin/LINKS

cd lib/bloomfilter/swig/

PERL5DIR=`(perl -e 'use Config; print $Config{archlibexp}, "\n";') 2>/dev/null`
swig -Wall -c++ -perl5 BloomFilter.i
g++ -c BloomFilter_wrap.cxx -I$PERL5DIR/CORE -fPIC -Dbool=char -O3
g++ -Wall -shared BloomFilter_wrap.o -o BloomFilter.so -O3


h2xs -n BloomFilter -O  -F -'I ../../../'
cd BloomFilter
perl Makefile.PL
make
make install
