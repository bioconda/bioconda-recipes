#!/bin/sh
make clean
make all VIENNA=$PREFIX

mv INFO-RNA-2.1.2 $PREFIX/bin
