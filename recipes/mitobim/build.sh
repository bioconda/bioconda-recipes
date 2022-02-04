#!/bin/bash

mkdir -p $PREFIX/bin
cp MITObim.pl $PREFIX/bin/
cp misc_scripts/* $PREFIX/bin/
chmod +x $PREFIX/bin/*
