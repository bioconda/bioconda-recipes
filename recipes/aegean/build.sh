sed -i.bak 's|=/usr/local|=${PREFIX}|g' Makefile
sed -i.bak 's/CC=gcc//g' Makefile
make install
make test
