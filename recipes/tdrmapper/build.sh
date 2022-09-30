#!/bin/bash

target=$PREFIX/lib/tdrmapper
mkdir -p $target
mkdir -p $PREFIX/bin
cp Scripts/*pl Scripts/*r $target
sed -i.bak 's:/usr/bin/perl:/usr/bin/env perl:' $target/TdrMappingScripts.pl
chmod +x $target/TdrMappingScripts.pl
ln -s $target/TdrMappingScripts.pl $PREFIX/bin/TdrMappingScripts.pl
