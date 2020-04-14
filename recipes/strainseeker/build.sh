#!/bin/bash

mkdir -p ${PREFIX}/bin
sed -i.bak '1 i\#!/usr/bin/env perl' scripts/seeker.pl

chmod 0755 scripts/*
chmod 0755 bin/*
cp scripts/* ${PREFIX}/bin/
cp bin/* $PREFIX/bin/
