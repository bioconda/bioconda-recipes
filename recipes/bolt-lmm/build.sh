#!/bin/bash

cd src

sed -i'.bak' 's/CC = icpc/CC = g++/g' Makefile

make CC=$CC

mkdir -p ${PREFIX}/bin

install -m775 bolt ${PREFIX}/bin/
