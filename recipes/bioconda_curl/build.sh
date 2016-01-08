#!/bin/bash

mkdir -p $PREFIX/etc/pki/tls/certs
#use system curl, or whatever comes with anaconda to get the CA certificates
curl http://curl.haxx.se/ca/cacert.pem -o $PREFIX/etc/pki/tls/certs/cacert.pem

#Actually install curl over the broken anaconda version
./configure --prefix=$PREFIX --disable-ldap --with-ssl=$PREFIX --with-zlib=$PREFIX --with-ca-path=$PREFIX/etc/pki/tls/certs --with-ca-bundle=$PREFIX/etc/pki/tls/certs/cacert.pem
make
make install
