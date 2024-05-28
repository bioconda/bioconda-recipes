#!/bin/bash

mkdir -p $PREFIX/bin && cp -r bin/* $PREFIX/bin && cp SSPACE_Basic.pl $PREFIX/bin && cp -r tools/* $PREFIX/bin
chmod +x $PREFIX/bin/*
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' $PREFIX/bin/*.pl
ln -s $PREFIX/bin/SSPACE_Basic.pl $PREFIX/bin/sspace_basic
mkdir -p $PREFIX/bin/dotlib && cp -r dotlib/* $PREFIX/bin/dotlib