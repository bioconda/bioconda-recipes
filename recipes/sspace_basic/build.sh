#!/bin/bash

# Copying the tools bin 
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/bin
cp -r bin/* $PREFIX/bin
cp -r bin/* $PREFIX/bin/bin  # Tool hardcoded the path of other used scripts to $Bin/bin/<tool>.pl
cp SSPACE_Basic.pl $PREFIX/bin 
cp -r tools/* $PREFIX/bin

# Copy dotlib 
mkdir -p $PREFIX/bin/dotlib 
cp -r dotlib/* $PREFIX/bin/dotlib

# Making the scripts executable
chmod +x $PREFIX/bin/*.pl $PREFIX/bin/bin/*

# Fixing the perl path
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' $PREFIX/bin/*.pl $PREFIX/bin/bin/*.pl

# Creating symlink of main tool
ln -s $PREFIX/bin/SSPACE_Basic.pl $PREFIX/bin/sspace_basic