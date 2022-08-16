#!/bin/bash

mkdir -p ${PREFIX}/lib/perl5/site_perl/Bio
mv lib/Bio/* ${PREFIX}/lib/perl5/site_perl/Bio

chmod +x bin/*
mkdir -p ${PREFIX}/bin
mv bin/* ${PREFIX}/bin
