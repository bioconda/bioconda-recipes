export LD_LIBRARY_PATH=${PREFIX}/lib/:${PREFIX}/lib/ghc-8.0.1/haskeline-0.7.2.3/:$LD_LIBRARY_PATH
CFLAGS="-L${PREFIX}/lib" ./configure --prefix=$PREFIX --libdir=${PREFIX}/lib/
export PATH=${PREFIX}/bin:$PATH
make install
