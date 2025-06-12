export MAXK=127
make metacortex
mkdir -p $PREFIX/bin
cp bin/metacortex_k127 $PREFIX/bin/metacortex
chmod +x $PREFIX/bin/metacortex