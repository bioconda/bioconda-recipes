#!/bin/bash

./configure --prefix=$PREFIX PERL='/usr/bin/env perl'
make
make check
make install
