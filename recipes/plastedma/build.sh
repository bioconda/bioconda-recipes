#!/bin/bash

echo $PREFIX

mkdir -p $PREFIX/
mkdir -p $PREFIX/share
cp -r * $PREFIX/share/

SHARE_FOLDER = $PREFIX/share/
for entry in "SHARE_FOLDER"/*
do
  echo "$entry"
done

ln -s $PREFIX/share/workflow $PREFIX/bin
ln -s $PREFIX/share/plastedma.py $PREFIX/bin
chmod +x $PREFIX/bin/plastedma.py