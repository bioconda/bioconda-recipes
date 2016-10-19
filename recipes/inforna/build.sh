#!/bin/sh
make clean
make all VIENNA=$PREFIX

mv INFO-RNA-2.1.2 $PREFIX/bin
ln -s $PREFIX/bin/INFO-RNA-2.1.2 $PREFIX/bin/INFO-RNA
