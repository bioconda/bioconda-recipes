export CXXFLAGS="${CXXFLAGS} -std=c++11 -lstdc++ -x c++"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L$PREFIX/lib"
export PBBAM_INC=$PREFIX/include
export PBBAM_LIB=$PREFIX/lib
export BOOST_INC=$PREFIX/include

NOPBBAM=1 NOHDF=1 ./configure.py PREFIX=$PREFIX
make all
ls alignment
cp alignment/*.so $PREFIX/lib
cp hdf/*.so $PREFIX/lib
cp pbdata/*.so $PREFIX/lib
ls $PREFIX/lib/