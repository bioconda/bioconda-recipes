#!/bin/bash
make
mkdir -p $PREFIX/bin
cp pbgzip $PREFIX/bin
