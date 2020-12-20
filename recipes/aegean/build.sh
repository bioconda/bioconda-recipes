sed -i.bak 's|=/usr/local|=${PREFIX}|g' Makefile
make install
make test
