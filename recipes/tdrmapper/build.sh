#!/bin/bash

target=$PREFIX/tdrmapper
mkdir $target
mkdir -p $PREFIX/bin
cp Scripts/*pl Scripts/*r $target/.
ln -s $target/TdrMappingScripts.pl $PREFIX/bin/TdrMappingScripts.pl
