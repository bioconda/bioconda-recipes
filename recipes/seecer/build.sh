chmod 755 *

./configure && make

mkdir -p "${PREFIX}/bin"
mv bin/* "$PREFIX/bin/"
