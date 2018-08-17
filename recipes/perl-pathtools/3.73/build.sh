#!/bin/bash

perl Makefile.PL PREFIX=${PREFIX}
make
make test
make install
