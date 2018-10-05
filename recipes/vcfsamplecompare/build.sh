#!/bin/bash

set -e

perl Makefile.PL
make
make install
