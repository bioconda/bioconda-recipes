export CXXFLAGS="${CXXFLAGS} -std=c++11 -lstdc++ -x c++"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L$PREFIX/lib"
export PBBAM_INC=$PREFIX/include
export PBBAM_LIB=$PREFIX/lib
export BOOST_INC=$PREFIX/include

NOPBBAM=1 NOHDF=1 ./configure.py PREFIX=$PREFIX
make all
cp alignment/libblasr.* $PREFIX/lib
cp hdf/libpbihdf.* $PREFIX/lib
cp pbdata/libpbdata.* $PREFIX/lib