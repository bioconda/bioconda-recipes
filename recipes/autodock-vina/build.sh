#!/bin/bash
mkdir -p $PREFIX/bin
cp -R ./bin/* $PREFIX/bin
chmod 0755 ${PREFIX}/bin/*
