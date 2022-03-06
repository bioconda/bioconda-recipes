chmod 755 *

./configure && make

ls -l

mkdir -p "${PREFIX}/bin"
mv bin/* "$PREFIX/bin/"
