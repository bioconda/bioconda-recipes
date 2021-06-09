mkdir -p $PREFIX/bin

#Copying perl script to bin folder
cp  LINKS $PREFIX/bin
chmod +x $PREFIX/bin/LINKS


set -eux -o pipefail

#Recompiling C code
cd lib/bloomfilter/swig/

if [[ $OSTYPE == linux* ]]; then
	suffix="so"
else
	suffix="dylib"
fi


PERL5DIR=`(perl -e 'use Config; print $Config{archlibexp}, "\n";') 2>/dev/null`
swig -Wall -c++ -perl5 BloomFilter.i
${CXX} -c BloomFilter_wrap.cxx -I$PERL5DIR/CORE -fPIC -O3
${CXX} -Wall -shared BloomFilter_wrap.o -o BloomFilter.${suffix} -O3 -L$PERL5DIR/CORE -lperl

mkdir -p $PREFIX/lib/site_perl/BloomFilter

cp BloomFilter.* $PREFIX/lib/site_perl/BloomFilter

