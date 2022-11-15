#!/usr/bin/env bash

perl Makefile.PL PREFIX=${PREFIX}
make
make install