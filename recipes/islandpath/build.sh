#!/usr/bin/env bash
mkdir -p $PREFIX/islandpath
cp -r . $PREFIX/islandpath
mkdir -p $PREFIX/bin
ln -s $PREFIX/islandpath/Dimob.pl $PREFIX/bin/islandpath
chmod +x $PREFIX/bin/*
export HOME=/tmp 
cpanm --force TAP::Harness::Env ExtUtils::Helpers
cpanm MooseX::Singleton
