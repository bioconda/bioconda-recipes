export BOOST_INCLUDE=$PREFIX/include
./configure.py --no-pbbam --sub
make init-submodule
make

mkdir -p $PREFIX/bin
cp src/cpp/pbdagcon $PREFIX/bin
cp src/cpp/dazcon $PREFIX/bin