#!/bin/bash

#env -u PERL5LIB -u PERL5DIR -u PERL_DIR 
nautoreconf --install
./configure --prefix=${PREFIX}
make install
