#!/bin/sh

cmake .
make
make install PREFIX=$PREFIX
