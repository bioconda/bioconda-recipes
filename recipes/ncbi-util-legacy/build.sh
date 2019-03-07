#!/bin/bash

>&2 ls 
>&2 ls ncbi/make

# chanhe makedis interpreter to tcsh
sed -i -e '1s@#!.*@#!/usr/bin/env tcsh@' ./ncbi/make/makedis.csh
./ncbi/make/makedis.csh

>&2 ls ncbi/build
