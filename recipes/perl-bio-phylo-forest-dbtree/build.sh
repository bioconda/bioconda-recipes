#!/bin/bash

# Install dependencies - at this point cpanm should be there
HOME=/tmp cpanm DBIx::Class

# Make sure this goes in conda $PREFIX
perl Makefile.PL INSTALL_BASE=$PREFIX
make
make test
make install
