#!/bin/bash

target=$PREFIX/lib/tdrmapper
mkdir -p $target
mkdir -p $PREFIX/bin
cp Scripts/*pl Scripts/*r $target
chmod +x $target/TdrMappingScripts.pl
ln -s $target/TdrMappingScripts.pl $PREFIX/bin/TdrMappingScripts.pl
