#!/bin/bash

# Set the environment variable
export QT_SELECT=5

# Run qmake to generate a Makefile
qmake Bandage.pro

# fix the makefile
sed -i 's/isystem/I/' Makefile

# Build the program
make

# Install
cp Bandage $PREFIX/bin
