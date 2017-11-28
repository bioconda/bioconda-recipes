#!/bin/bash

curl -L cpanmin.us | perl - --installdeps .
perl Makefile.PL
make
make test
make install
