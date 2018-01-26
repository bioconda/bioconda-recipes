mkdir -p $PREFIX/bin
cp ./* $PREFIX/bin/

# scons PREFIX=$PREFIX BOOST_DIR=$PREFIX install
