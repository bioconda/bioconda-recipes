sed -i.bak "s/CPP=g++/CPP=\${GXX}/" src/Makefile
sed -i.bak "s/-o clan_search/-o clan_search -lrt/" src/Makefile
sed -i.bak "s/-o clan_annotate/-o clan_annotate -lrt/" src/Makefile
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/

