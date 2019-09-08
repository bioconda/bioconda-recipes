#!/bin/bash

./configure --prefix=${PREFIX}             \
            --enable-opie                  \
            --enable-digest                \
            --enable-ntlm                  \
            --enable-debug                 \
            --with-ssl=openssl             \
            --with-openssl=${PREFIX}       \
            --with-zlib=${PREFIX}          \
            --with-metalink                \
            --with-cares                   \
            --with-libpsl                  \
	    CC=${CC}
make
make install
