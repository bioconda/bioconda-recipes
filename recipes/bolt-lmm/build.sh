#!/bin/bash

cd src

sed -i'.bak' 's/CC = icpc/CC = g++/g' Makefile

make

mkdir -p ${PREFIX}/bin

install -m775 bolt ${PREFIX}/bin/
