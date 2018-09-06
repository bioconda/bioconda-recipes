#!/bin/bash

# Set the environment variable
export QT_SELECT=5

# Run qmake to generate a Makefile
qmake

# Build the program
make

# Install
make install
