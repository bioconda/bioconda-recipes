make Compiler=$CXX CXX=$CXX CC=$CC  LDFLAGS="-L${PREFIX}/lib" CFLAGS="-I${PREFIX}/include" CXXFLAGS="-I${PREFIX}/include"
if [ ! -d $PREFIX/bin ] ; then
  mkdir $PREFIX/bin
fi

cp MapCaller bwt_index $PREFIX/bin