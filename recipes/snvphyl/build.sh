#!/bin/bash


# Make sure this goes in site
perl Makefile.PL INSTALLDIRS=site
make
perl t/consolidate_vcfs.t #only testing script that uses bcftools,
#otherwise we timeout when testing on travis
make install
