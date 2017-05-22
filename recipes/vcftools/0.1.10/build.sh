#!/bin/bash

sed -i -e 's/DIRS = cpp perl/DIRS = cpp/' ./Makefile
make
make install
