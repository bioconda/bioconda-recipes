chmod 755 *

cd SEECER

./configure --seqan-include-path $PREFIX && make

mkdir -p "${PREFIX}/bin"
mv bin/* "$PREFIX/bin/"
