#! /bin/bash

mkdir -p $PREFIX/bin
cp -R txt/* $PREFIX/bin/
chmod +x $PREFIX/bin/*
