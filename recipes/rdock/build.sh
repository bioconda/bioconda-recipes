cd build
chmod +x p4utils.pl

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
