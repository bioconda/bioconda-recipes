sed -i.bak 's|=/usr/local|=${PREFIX}|g' Makefile
sed -i.bak 's/gcc/${CC}/g' Makefile
make install
make test
