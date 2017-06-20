#!/bin/bash

mkdir -p $PREFIX/bin

make
cp bin/edena $PREFIX/bin