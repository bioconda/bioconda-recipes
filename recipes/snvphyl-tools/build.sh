#!/bin/bash


# Make sure this goes in site
perl Makefile.PL INSTALLDIRS=site
make

make install
