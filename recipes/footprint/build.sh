#!/bin/bash

./configure --prefix=$PREFIX PERL='/usr/bin/env perl' GNUBASH='/bin/bash'
make
make check
make install
