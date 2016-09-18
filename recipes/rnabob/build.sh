#!/bin/sh
make clean
make
make install HOME=$PREFIX
