#! /bin/sh

mkdir -p $PREFIX/bin
cp -R script/* $PREFIX/bin/
chmod +x $PREFIX/bin/*
