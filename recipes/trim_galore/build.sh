#!/bin/bash

mkdir -p $PREFIX/bin
chmod a+x trim_galore
#/usr/bin/perl is hardcoded, need to point to env
sed -i '1s/perl/env perl/' trim_galore

cp trim_galore $PREFIX/bin
