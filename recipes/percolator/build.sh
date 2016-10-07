cmake . -DXML_SUPPORT=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX 
make
make install


curl -L http://fallabs.com/tokyocabinet/tokyocabinet-1.4.48.tar.gz -o tokyocabinet.tar.gz
tar xvfz tokyocabinet.tar.gz
cd tokyocabinet-1.4.48
./configure --prefix=$PREFIX --with-zlib=$PREFIX --with-bzip=$PREFIX
make
make install

export INCLUDE_PATH="${PREFIX}/include" 
export LIBRARY_PATH="${PREFIX}/lib" 
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib" 
export CPPFLAGS="-I${PREFIX}/include"
export PATH="${PREFIX}/bin":$PATH

cd ../src/converters
cmake -DBOOST_ROOT=$PREFIX -DSERIALIZE="TokyoCabinet" -DCMAKE_PREFIX_PATH=$PREFIX -DTokyoCabinet_INCLUDE_DIR=$PREFIX/include
make
make install
