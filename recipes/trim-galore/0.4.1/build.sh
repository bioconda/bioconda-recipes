#!/bin/bash

mkdir -p $PREFIX/bin
chmod a+x trim_galore
#/usr/bin/perl is hardcoded, need to point to env
sed -i.bak 's/perl/env perl/g' trim_galore

cp trim_galore $PREFIX/bin
