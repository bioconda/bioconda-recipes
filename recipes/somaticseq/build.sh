#!/usr/bin/env bash

mkdir -p $PREFIX/opt/SomaticSeq

for file in *
do
 mv $file $PREFIX/opt/SomaticSeq/
done

cd $PREFIX/opt/SomaticSeq
for script in *.sh *.py
do
  ln -s ../opt/SomaticSeq/$script $PREFIX/bin/$script
done

mkdir $PREFIX/bin/utilities
cd $PREFIX/bin/utilities
for file in *
do
  ln -s ../../opt/SomaticSeq/utilities/$file $PREFIX/bin/utilities/$file
done

mkdir $PREFIX/bin/r_scripts
for file in $prog_dir/r_scripts/*
do
  ln -s ../../opt/SomaticSeq/r_sripts/$file $PREFIX/bin/r_scripts/$file
done
