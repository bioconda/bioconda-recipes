#!/bin/sh

# replace perl with /usr/bin/env perl and remove -w flag
find . -name \*.pl -exec sed  -i 's^/usr/bin/perl -w^/usr/bin/env perl^' {} \;
./configure --prefix=$CONDA_PREFIX && make && make install
