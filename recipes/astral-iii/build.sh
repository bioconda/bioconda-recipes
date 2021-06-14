#!/usr/bin/env bash
mkdir $PREFIX/ASTRAL-5.7.3
cp -r * $PREFIX/ASTRAL-5.7.3/
mkdir $PREFIX/bin
ln -s $PREFIX/ASTRAL-5.7.3/astral $PREFIX/bin/astral