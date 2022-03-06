chmod 755 *

cd SEECER

./configure && make

mkdir -p "${PREFIX}/bin"
mv bin/* "$PREFIX/bin/"
