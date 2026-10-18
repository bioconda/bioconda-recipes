#!/usr/bin/env bash

mkdir -p $PREFIX/bin
chmod a+x scripts/*
find scripts -maxdepth 1 -type f | xargs -I {} cp {} $PREFIX/bin