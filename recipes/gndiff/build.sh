#!/bin/bash

go build
mkdir -p $PREFIX/bin
mv gndiff $PREFIX/bin
