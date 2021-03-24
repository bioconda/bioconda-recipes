#!/bin/bash

mkdir -p $PREFIX/bin
chmod +x abacas.1.3.1.pl
cp abacas.1.3.1.pl $PREFIX/bin
ln -s $PREFIX/bin/abacas.1.3.1.pl $PREFIX/bin/abacas.pl
