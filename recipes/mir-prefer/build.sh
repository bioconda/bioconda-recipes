#!/bin/bash

mkdir -p $PREFIX/bin

find . -name "*.py" | xargs -I {} mv {} $PREFIX/bin
