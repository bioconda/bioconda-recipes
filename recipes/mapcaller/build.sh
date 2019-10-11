make Compiler=$CXX CXX=$CXX CC=$CC  LDFLAGS="-L${PREFIX}/lib" CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib" CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
if [ ! -d $PREFIX/bin ] ; then
  mkdir $PREFIX/bin
fi

cp bin/MapCaller bin/bwt_index $PREFIX/bin