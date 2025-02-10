#!/bin/bash

# Copying the tools bin 
cp -r bin $PREFIX
cp -r bin $PREFIX/bin  # Tool hardcoded the path of other used scripts to $Bin/bin/<tool>.pl
cp SSPACE_Basic.pl $PREFIX/bin 
cp -r tools/* $PREFIX/bin

# Copy dotlib 
cp -r dotlib $PREFIX/bin

# Making the scripts executable
chmod +x $PREFIX/bin/*.pl $PREFIX/bin/bin/*

# Fixing the perl path
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' $PREFIX/bin/*.pl $PREFIX/bin/bin/*.pl

# Creating symlink of main tool
ln -s $PREFIX/bin/SSPACE_Basic.pl $PREFIX/bin/sspace_basic