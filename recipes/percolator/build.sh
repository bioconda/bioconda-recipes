cmake . -DXML_SUPPORT=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX 
make
make install


curl -L http://fallabs.com/tokyocabinet/tokyocabinet-1.4.48.tar.gz -o tokyocabinet.tar.gz
tar xvfz tokyocabinet.tar.gz
cd tokyocabinet-1.4.48
./configure --prefix=$PREFIX --with-zlib=$PREFIX --with-bzip=$PREFIX
make
make install

cmake -DTARGET_ARCH=x86_64 -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=$PREFIX -DBOOST_LIBRARYDIR=$PREFIX/lib -DSERIALIZE="TokyoCabinet" -DCMAKE_PREFIX_PATH="$PREFIX/lib" .
make
make install
