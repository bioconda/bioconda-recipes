#!/usr/bin/env bash

prog_dir=$PREFIX/opt/SomaticSeq

mkdir -p $prog_dir
mv ./* $prog_dir

cd $prog_dir
for script in *.sh *.py
do
  ln -s $prog_dir/$script $PREFIX/bin/$script
done

mkdir $PREFIX/bin/utilities
for file in $prog_dir/utilities/*
do
  ln -s $prog_dir/utilities/$file $PREFIX/bin/utilities/$file
done

mkdir $PREFIX/bin/r_scripts
for file in $prog_dir/r_scripts/*
do
  ln -s $prog_dir/r_sripts/$file $PREFIX/bin/r_scripts/$file
done
