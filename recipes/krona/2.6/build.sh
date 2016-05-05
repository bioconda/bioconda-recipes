#!/bin/sh
mkdir -p $PREFIX/opt/krona
mv ./* $PREFIX/opt/krona
cd $PREFIX/opt/krona
./install.pl --prefix=$PREFIX

sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' $PREFIX/bin/* 
