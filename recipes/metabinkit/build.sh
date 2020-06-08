#!/usr/bin/env bash

# run the install script with -C (conda mode)
./install.sh -i $PREFIX -C
cp exe/* $PREFIX/bin/
