#!/bin/bash

sed -i.bak 's@#! /usr/local/bin/perl@#!/opt/anaconda1anaconda2anaconda3/bin/perl@g' *.pl

chmod +x *.pl

cp *.pl ${PREFIX}/bin

# copy perl libraries
perl_version=$(perl -e 'print $^V');
perl_version=${perl_version:1}
cp Codon.pm ${PREFIX}/lib/${perl_version}/
