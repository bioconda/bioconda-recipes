#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
cp bin/* $BIN/
rapid=$PREFIX/bin
chmod 755 $rapid/*
