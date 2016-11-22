#!/bin/bash

mkdir -p $PREFIX/bin
make
make install PREFIX=$PREFIX

