chmod 755 *

cd SEECER

./configure && make CC=$CC

mkdir -p "${PREFIX}/bin"
mv bin/* "$PREFIX/bin/"
