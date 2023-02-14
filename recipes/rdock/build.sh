cd build
chmod +x p4utils.pl

# Needs -std=c++14 because of
#   error: ISO C++17 does not allow dynamic exception specifications
export CXXFLAGS="${CXXFLAGS} -std=c++14"

sed -i \
  -e "/^TMAKE_CC\s*=/          s|=.*|= ${CC}|" \
  -e "/^TMAKE_CXX\s*=/         s|=.*|= ${CXX}|" \
  -e "/^TMAKE_LINK\s*=/        s|=.*|= ${CXX}|" \
  -e "/^TMAKE_LINK_SHLIB\s*=/  s|=.*|= ${CXX}|" \
  -e "/^TMAKE_CFLAGS\s*=/      s|=\s*|&${CFLAGS} |" \
  -e "/^TMAKE_CXXFLAGS\s*=/    s|=\s*|&${CXXFLAGS} |" \
  -e "/^TMAKE_LFLAGS\s*=/      s|=\s*|&${LDFLAGS} |" \
  tmakelib/linux-g++-64/tmake.conf

make linux-g++-64 BINDIR=$PREFIX/bin LIBDIR=$PREFIX/lib

# compiled binaries are in bin, cp the scripts over too
cp ../bin/* $PREFIX/bin
mkdir -p $PREFIX/lib/perl5/vendor_perl
cp ../lib/* $PREFIX/lib/perl5/vendor_perl

# so the perl lib files are accessible
#mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d

#echo "export PERL5LIB=$PERL5LIB:$PREFIX/lib" > ${PREFIX}/etc/conda/activate.d/rdock-perl5lib.sh
#chmod a+x ${PREFIX}/etc/conda/activate.d/rdock-perl5lib.sh

#echo "unset PERL5LIB" > ${PREFIX}/etc/conda/deactivate.d/rdock-perl5lib.sh
#chmod a+x ${PREFIX}/etc/conda/deactivate.d/rdock-perl5lib.sh
